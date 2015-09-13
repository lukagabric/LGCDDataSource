//
//  LGDataSource.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 13/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "LGDataSource.h"
#import <CoreData/CoreData.h>
#import "LGDataUpdateInfo.h"
#import "LGDataDownloadOperation.h"
#import "LGResponse.h"

@interface LGDataSource ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *bgContext;
@property (strong, nonatomic) NSOperationQueue *dataDownloadQueue;
@property (strong, nonatomic) NSCache *lastUpdateDateCache;
@property (strong, nonatomic) NSCache *fingerprintCache;
@property (strong, nonatomic) NSMutableDictionary *activeDataUpdates;

@end

@implementation LGDataSource

#pragma mark - Init

- (instancetype)initWithSession:(NSURLSession *)session
                    mainContext:(NSManagedObjectContext *)mainContext {
    self = [super init];
    if (self) {
        self.session = session;

        self.mainContext = mainContext;
        self.bgContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.bgContext.parentContext = self.mainContext;
        
        self.dataDownloadQueue = [NSOperationQueue new];
        self.dataDownloadQueue.maxConcurrentOperationCount = 1;
        self.dataDownloadQueue.suspended = NO;
        
        self.activeDataUpdates = [NSMutableDictionary new];
        
        self.lastUpdateDateCache = [NSCache new];
        self.lastUpdateDateCache.countLimit = 100;

        self.fingerprintCache = [NSCache new];
        self.fingerprintCache.countLimit = 100;
    }
    return self;
}

#pragma mark - Update Promise

- (PMKPromise *)updateDataPromiseWithRequest:(NSURLRequest *)request
                                   requestId:(NSString *)requestId
                               staleInterval:(NSTimeInterval)staleInterval
                                  dataUpdate:(LGDataUpdate)dataUpdate {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (![self isDataStaleForRequestId:requestId andStaleInterval:staleInterval]) return nil;

    PMKPromise *activeDataUpdatePromise = self.activeDataUpdates[requestId];
    if (activeDataUpdatePromise) {
        return activeDataUpdatePromise;
    }
    
    LGDataDownloadOperation *downloadOperation = [[LGDataDownloadOperation alloc] initWithSession:self.session request:request];
    [self.dataDownloadQueue addOperation:downloadOperation];
    
    PMKPromise *downloadPromise = downloadOperation.promise;
    
    __weak id weakSelf = self;
    PMKPromise *dataUpdatePromise = downloadPromise.then(^id(LGResponse *response) {
        return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            LGDataSource *strongSelf = weakSelf;
            if (!strongSelf) {
                fulfill(nil);
                return;
            }
            
            NSError *responseValidationError = [strongSelf validateResponse:response];
            if (responseValidationError) {
                reject(responseValidationError);
                return;
            }
            
            if (![strongSelf isDataNewForRequestId:requestId response:response]) {
                fulfill(nil);
                return;
            }
            
            [strongSelf.bgContext performBlock:^{
                LGDataSource *strongSelf = weakSelf;
                if (!strongSelf) return fulfill(nil);
                
                NSError *serializationError;
                id responseObject = [strongSelf serializedResponseDataForResponse:response error:&serializationError];
                
                if (responseObject == nil || serializationError) {
                    reject(serializationError);
                    return;
                }
                
                id <LGContextTransferable> dataUpdateResult = dataUpdate(responseObject, response, strongSelf.bgContext);
                
                LGDataUpdateInfo *info = [self existingUpdateInfoForRequestId:requestId context:strongSelf.bgContext];
                if (!info) info = [self newUpdateInfoForRequestId:requestId context:strongSelf.bgContext];
                
                info.lastUpdateDate = [NSDate date];
                info.responseFingerprint = [strongSelf fingerprintForResponse:response];

                [strongSelf saveDataWithCompletionBlock:^{
                    LGDataSource *strongSelf = weakSelf;
                    if (!strongSelf) return;
                    
                    id transferredResult = [dataUpdateResult transferredToContext:self.mainContext];

                    [strongSelf.lastUpdateDateCache setObject:info.lastUpdateDate forKey:requestId];
                    [strongSelf.fingerprintCache setObject:info.responseFingerprint forKey:requestId];

                    fulfill(transferredResult);
                }];
            }];
        }];
    });
    
    self.activeDataUpdates[requestId] = dataUpdatePromise;

    return dataUpdatePromise;
}


#pragma mark - Convenience

- (BOOL)isDataStaleForRequestId:(NSString *)requestId andStaleInterval:(NSTimeInterval)staleInterval {
    NSDate *lastUpdateDate = [self lastUpdateDateForRequestId:requestId];
    NSTimeInterval lastUpdateInterval = [lastUpdateDate timeIntervalSinceReferenceDate];
    NSTimeInterval staleAtInterval = lastUpdateInterval + staleInterval;
    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval dataValidForInterval = staleAtInterval - currentTimeInterval;
    
    BOOL isDataStale = !lastUpdateDate || [(NSDate *)[lastUpdateDate dateByAddingTimeInterval:staleInterval] compare:[NSDate date]] != NSOrderedDescending;
    
#if DEBUG
    if (!isDataStale) {
        NSLog(@"Not updating because data is not stale. Stale interval is set to %.0f second(s). Last update was at %@ so data is valid for another %.0f second(s).", staleInterval, lastUpdateDate, ceil(dataValidForInterval));
    }
#endif
    
    return isDataStale;
}

- (NSDate *)lastUpdateDateForRequestId:(NSString *)requestId {
    NSDate *cachedLastUpdateDate = [self.lastUpdateDateCache objectForKey:requestId];
    if (cachedLastUpdateDate) return cachedLastUpdateDate;
    
    LGDataUpdateInfo *info = [self existingUpdateInfoForRequestId:requestId context:self.mainContext];
    return info.lastUpdateDate;
}

- (BOOL)isDataNewForRequestId:(NSString *)requestId response:(LGResponse *)response {
    NSString *currentFingerprint = [self fingerprintForResponse:response];

    NSString *previousFingerprint = [self.fingerprintCache objectForKey:requestId];
    if (!previousFingerprint) {
        LGDataUpdateInfo *info = [self existingUpdateInfoForRequestId:requestId context:self.mainContext];
        previousFingerprint = info.responseFingerprint;
    }
    
    BOOL isDataNew = !previousFingerprint || !currentFingerprint || ![previousFingerprint isEqualToString:currentFingerprint];
    
#if DEBUG
    NSLog(@"Data is %@new for this request.", isDataNew ? @"" : @"NOT ");
#endif
    
    return isDataNew;
}

- (NSString *)fingerprintForResponse:(LGResponse *)response {
    NSDictionary *headers = response.httpResponse.allHeaderFields;
    
    NSString *etagOrLastModified = headers[@"Etag"];
    
    if (!etagOrLastModified) {
        etagOrLastModified = headers[@"Last-Modified"];
    }
    
#if DEBUG
    if (!etagOrLastModified) {
        NSLog(@"No response fingerprint for request with url: '%@'. Request needs to have a fingerprint (e.g. ETag or Last-Modified) for caching.", response.httpResponse.URL.absoluteString);
    }
#endif
    
    return etagOrLastModified;
}

- (NSError *)validateResponse:(LGResponse *)response {
    return nil;
}

- (id)serializedResponseDataForResponse:(LGResponse *)response error:(NSError **)error {
    return [NSJSONSerialization JSONObjectWithData:response.responseData
                                           options:kNilOptions
                                             error:error];
}

#pragma mark - Data Update Info

- (LGDataUpdateInfo *)existingUpdateInfoForRequestId:(NSString *)requestId context:(NSManagedObjectContext *)context {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LGDataUpdateInfo"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"requestId == %@", requestId];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    
    NSAssert(error == nil, @"Error fetching data update info");
    if (error) return nil;
    
    return [results firstObject];
}

- (LGDataUpdateInfo *)newUpdateInfoForRequestId:(NSString *)requestId context:(NSManagedObjectContext *)context {
    LGDataUpdateInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"LGDataUpdateInfo" inManagedObjectContext:context];
    info.requestId = requestId;
    return info;
}

#pragma mark - Save

- (void)saveDataWithCompletionBlock:(void (^)(void))completionBlock {
    [self.bgContext save:nil];
    
    [self.mainContext performBlockAndWait:^{
        [self.mainContext save:nil];
        if (completionBlock) completionBlock();
        
        NSManagedObjectContext *rootContext = self.mainContext.parentContext;
        if (rootContext) {
            [rootContext performBlock:^{
                [rootContext save:nil];
            }];
        }
    }];
}

#pragma mark -

@end

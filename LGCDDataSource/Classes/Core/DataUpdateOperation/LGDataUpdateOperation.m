//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperation_Internal.h"
#import "LGDataUpdateInfo.h"
#import "PromiseKit.h"

@implementation LGDataUpdateOperation {
    BOOL _finished;
    BOOL _executing;
}

#pragma mark - Init

- (instancetype)initWithSession:(NSURLSession *)session
                        request:(NSURLRequest *)request
                      requestId:(NSString *)requestId
                    mainContext:(NSManagedObjectContext *)mainContext
                      bgContext:(NSManagedObjectContext *)bgContext
                     dataUpdate:(LGDataUpdate)dataUpdate {
    self = [super init];
    if (self) {
        NSAssert(session && request && requestId, @"Dependencies are mandatory");
        
        self.session = session;
        self.requestId = requestId;
        self.mainContext = mainContext;
        self.bgContext = bgContext;
        self.dataUpdate = dataUpdate;
        
        __weak id weakSelf = self;
        self.promise = [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            LGDataUpdateOperation *strongSelf = weakSelf;
            if (!strongSelf) return;

            strongSelf.fulfill = fulfill;
            strongSelf.reject = reject;
        }];
        
        self.task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            LGDataUpdateOperation *strongSelf = weakSelf;
            if (!strongSelf) return;

            [strongSelf.bgContext performBlockAndWait:^{
                [self taskFinishedWithData:data response:response andError:error];
            }];
        }];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
#if DEBUG
    NSLog(@"%@ dealloc", [self class]);
#endif
}

#pragma mark - Task finished

- (void)taskFinishedWithData:(NSData *)data response:(NSURLResponse *)response andError:(NSError *)error {
    if ([self isCancelled]) return;
    
    self.responseData = data;
    self.response = response;
    self.error = error;
    self.dataUpdateInfo = [self existingInfo] ?: [self newInfo];

    if ([self isCancelled]) return;
    
    if (self.error) {
        [self finishOperation];
        return;
    }
    
    self.error = [self validateResponse];
    
    if (self.error) {
        [self finishOperation];
        return;
    }
    
    if ([self isCancelled]) return;
    
    if ([self isDataNew]) {
        self.dataUpdateInfo.responseFingerprint = self.responseFingerprint;
        
        id result = [self parseData];
        
        if ([result isKindOfClass:[NSError class]]) {
            self.error = result;
            [self finishOperation];
            return;
        }
        else {
            self.dataUpdateResult = result;
        }
    }
    
    self.dataUpdateInfo.lastUpdateDate = [NSDate date];
    
    if ([self isCancelled]) return;
    
    self.error = [self saveContexts];
    [self finishOperation];
}

#pragma mark - Check if response is valid

- (NSError *)validateResponse {
    return nil;
}

#pragma mark - Is Data New

- (BOOL)isDataNew {
    NSString *previousFingerprint = self.dataUpdateInfo.responseFingerprint;;
    NSString *currentFingerprint = self.responseFingerprint;
    
    BOOL isDataNew = !previousFingerprint || !currentFingerprint || ![previousFingerprint isEqualToString:currentFingerprint];
    
#if DEBUG
    NSLog(@"Data is %@new for this request.", isDataNew ? @"" : @"NOT ");
#endif
    
    return isDataNew;
}

#pragma mark - Parse data

- (id)parseData {
    __block id dataUpdateResult;

    if (!self.dataUpdate) return nil;
    
    dataUpdateResult = self.dataUpdate(self.serializedResponseData ?: self.responseData, self.response, self.bgContext);
    
    if ([dataUpdateResult respondsToSelector:@selector(transferredToContext:)]) {
        [self.mainContext performBlockAndWait:^{
            dataUpdateResult = [dataUpdateResult transferredToContext:self.mainContext];
        }];
    }
    
    return dataUpdateResult;
}

#pragma mark - Response serializer

- (id)serializedResponseData {
    return [NSJSONSerialization JSONObjectWithData:self.responseData
                                           options:kNilOptions
                                             error:nil];
}

#pragma mark - Get response fingerprint

- (NSString *)responseFingerprint {
    NSDictionary *headers = [(NSHTTPURLResponse *)self.response allHeaderFields];
    
    NSString *etagOrLastModified = [headers objectForKey:@"Etag"];
    
    if (!etagOrLastModified) {
        etagOrLastModified = [headers objectForKey:@"Last-Modified"];
    }
    
#if DEBUG
    if (!etagOrLastModified) {
        NSLog(@"No response fingerprint for request with url: '%@' and identifier: '%@'. Request needs to have a fingerprint (e.g. ETag or Last-Modified) for caching.", [self.response.URL absoluteString], self.requestId);
    }
#endif
    
    return etagOrLastModified;
}

#pragma mark - Refresh Data Update Info

- (LGDataUpdateInfo *)existingInfo {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LGDataUpdateInfo"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"requestId = %@", self.requestId];
    
    NSError *error;
    NSArray *results = [self.bgContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) return nil;
    
    return [results firstObject];
}

- (LGDataUpdateInfo *)newInfo {
    LGDataUpdateInfo *info = [NSEntityDescription insertNewObjectForEntityForName:@"LGDataUpdateInfo" inManagedObjectContext:self.bgContext];
    info.requestId = self.requestId;
    return info;
}

#pragma mark - Save contexts

- (NSError *)saveContexts {
    NSError *saveError;
    
    if ([self.bgContext hasChanges]) {
        NSError *(^saveBlock)(NSManagedObjectContext *context) = ^NSError *(NSManagedObjectContext *context) {
            __block NSError *error;
            
            [context performBlockAndWait:^{
                NSError *e;
                [context save:&e];
                error = e;
            }];
            
            return error;
        };
        
        saveError = saveBlock(self.bgContext);
        if (!saveError) {
            saveError = saveBlock(self.mainContext);
        }

        if (self.mainContext.parentContext) {
            [LGDataUpdateOperation asyncPersistContext:self.mainContext.parentContext];
        }
        
#if DEBUG
        if (saveError) {
            NSLog(@"Context Save Error: '%@'", self.error);
        }
#endif
    }
#if DEBUG
    else {
        NSLog(@"NOT saving, no changes in bg context for request id '%@'", self.requestId);
    }
#endif
    
    return saveError;
}

+ (void)asyncPersistContext:(NSManagedObjectContext *)context {
    [context performBlock:^{
        [context save:nil];
        
        if (context.parentContext) {
            [self asyncPersistContext:context.parentContext];
        }
    }];
}

#pragma mark - NSOperation

- (void)start {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [_task resume];
}

- (void)finishOperation {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(finishOperation) withObject:nil waitUntilDone:NO];
        return;
    }
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    if (self.error) {
        self.reject(self.error);
    }
    else {
        self.fulfill(self.dataUpdateResult);
    }
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)cancel {
    [self.task cancel];
    [super cancel];
}

#pragma mark -

@end

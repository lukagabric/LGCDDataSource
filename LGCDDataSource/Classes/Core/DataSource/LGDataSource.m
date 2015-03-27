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
#import "LGDataUpdateOperation.h"

@interface LGDataSource ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *bgContext;
@property (strong, nonatomic) NSOperationQueue *dataUpdateQueue;

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
        [self configureBgContextNotifications];
        
        self.dataUpdateQueue = [NSOperationQueue new];
        self.dataUpdateQueue.maxConcurrentOperationCount = 1;
        self.dataUpdateQueue.suspended = NO;
    }
    return self;
}

#pragma mark - Update Promise

- (PMKPromise *)updateDataPromiseWithRequest:(NSURLRequest *)request
                                   requestId:(NSString *)requestId
                               staleInterval:(NSTimeInterval)staleInterval
                                  dataUpdate:(LGDataUpdate)dataUpdate {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if ([self isDataStaleForRequestId:requestId andStaleInterval:staleInterval]) {
        LGDataUpdateOperation *operation = [self operationWithRequest:request
                                                            requestId:requestId
                                                           dataUpdate:dataUpdate];
        return operation.promise;
    }
    
    return nil;
}

#pragma mark - Update Operation

- (LGDataUpdateOperation *)operationWithRequest:(NSURLRequest *)request
                                  requestId:(NSString *)requestId
                                 dataUpdate:(LGDataUpdate)dataUpdate {
    LGDataUpdateOperation *operation;
    
    for (LGDataUpdateOperation *existingOperation in self.dataUpdateQueue.operations) {
        if ([existingOperation.requestId isEqualToString:requestId]) {
            operation = existingOperation;
            break;
        }
    }
    
    if (!operation) {
        operation = [[LGDataUpdateOperation alloc] initWithSession:self.session
                                                           request:request
                                                         requestId:requestId
                                                       mainContext:self.mainContext
                                                         bgContext:self.bgContext
                                                        dataUpdate:dataUpdate];
        [self.dataUpdateQueue addOperation:operation];
    }
    
    return operation;
}

#pragma mark - Update date

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
    __block NSDate *lastUpdateDate;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[LGDataUpdateInfo entityName]];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"requestId = %@", requestId];
    
    [self.bgContext performBlockAndWait:^{
        NSError *error;
        NSArray *results = [self.bgContext executeFetchRequest:fetchRequest error:&error];
        
        if (error) return;
        
        LGDataUpdateInfo *info = [results firstObject];
        lastUpdateDate = info.lastUpdateDate;
    }];
    
    return lastUpdateDate;
}

#pragma mark - Bg Context Notifications

- (void)configureBgContextNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(bgContextWillSave)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:self.bgContext];
}

- (void)bgContextWillSave {
    NSSet *insertedObjects = [self.bgContext insertedObjects];
    
    if ([insertedObjects count] == 0) return;
    
#if DEBUG
    NSLog(@"Obtaining permanent object IDs");
#endif

    NSError *error = nil;
    [self.bgContext obtainPermanentIDsForObjects:[insertedObjects allObjects] error:&error];
}

#pragma mark -

@end

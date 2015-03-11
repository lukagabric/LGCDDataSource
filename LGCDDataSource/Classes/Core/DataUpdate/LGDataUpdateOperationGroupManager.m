//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationGroupManager.h"
#import <CoreData/CoreData.h>
#import "CoreData+MagicalRecord.h"
#import "MBProgressHUD.h"
#import "LGDataUpdateGroup.h"


#define kDataUpdateOperationGroupLastUpdateDateFormat @"kDataUpdateOperationGroupLastUpdateDateFormat.groupId.%@"


@implementation LGDataUpdateOperationGroupManager


#pragma mark - Init & dealloc


static NSOperationQueue *dataUpdateQueue;


+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataUpdateQueue = [NSOperationQueue new];
        dataUpdateQueue.maxConcurrentOperationCount = 1;
        [dataUpdateQueue setSuspended:NO];
    });
}


- (instancetype)initWithUpdateOperations:(NSArray *)updateOperations andGroupId:(NSString *)groupId
{
	self = [super init];
	if (self)
	{
        _updateOperations = [updateOperations copy];
        _groupId = groupId;
        [self initialize];
	}
	return self;
}


- (void)initialize
{
    [self createWorkerContext];
    
    _saveAfterLoad = YES;
    _cacheValidTime = 900;
    
    for (LGDataUpdateOperation *operation in _updateOperations)
    {
        operation.dataUpdateDelegate = self;
        operation.workerContext = _workerContext;
    }
}


- (void)dealloc
{
    [self freeWorkerContext];
    
#if DEBUG
    NSLog(@"%@ dealloc", [self class]);
#endif
}


#pragma mark - State methods


- (void)loadDidStart
{
    _finished = NO;
    _running = YES;
    _newData = NO;
    _cancelled = NO;
    _error = nil;
}


- (void)loadDidFinishWithError:(NSError *)error canceled:(BOOL)canceled forceNewData:(BOOL)forceNewData
{
    _finished = YES;
    _running = NO;
    _cancelled = canceled;
    _error = error;
    
    if (error || canceled)
        _newData = NO;
    else if (forceNewData)
        _newData = YES;
    else
        _newData = [_workerContext hasChanges];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_updateCompletionBlock && !_cancelled)
            _updateCompletionBlock(_error, _newData);
        
        if (_activityView)
            [self hideProgressForActivityView];
    });
}


#pragma mark - Public methods


- (void)updateDataIgnoringCacheIntervalWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    [self updateDataIgnoringCacheInterval:YES withCompletionBlock:completionBlock];
}


- (void)updateDataWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    [self updateDataIgnoringCacheInterval:NO withCompletionBlock:completionBlock];
}


- (void)updateDataIgnoringCacheInterval:(BOOL)ignoreCacheInterval
                    withCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    NSAssert(!_running, @"Trying to start request that is already running");
    
    if (_running) return;
    
    _updateCompletionBlock = [completionBlock copy];
    
    [self loadDidStart];
    
    if ([self isGroupDataStale] || ignoreCacheInterval)
    {
        if (_activityView)
            [self showProgressForActivityView];
    ;
        if ([_updateOperations count] == 0)
        {
            [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
            return;
        }
        
        [dataUpdateQueue addOperations:_updateOperations waitUntilFinished:NO];
    }
    else
    {
        NSDate *lastUpdateDate = [self groupUpdateDate];
        
        NSTimeInterval lastUpdateInterval = [lastUpdateDate timeIntervalSinceReferenceDate];
        NSTimeInterval staleAtInterval = lastUpdateInterval + _cacheValidTime;
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
        NSTimeInterval dataValidForInterval = staleAtInterval - currentTimeInterval;

#if DEBUG
        NSLog(@"Not updating because data is not stale. Group cache valid time is set to %ld second(s). Last update was at %@ so data is valid for another %.0f second(s).", _cacheValidTime, lastUpdateDate, dataValidForInterval);
#endif
        
        [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
}


- (void)cancelLoad
{
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    
    if (_finished || _cancelled) return;
    
    [self loadDidFinishWithError:nil canceled:YES forceNewData:NO];
    
    for (LGDataUpdateOperation *operation in _updateOperations)
        [operation cancel];
}


#pragma mark - LDataUpdateOperationDelegate


- (void)operation:(LGDataUpdateOperation *)operation didFinishWithError:(NSError *)error
{
    if (_cancelled) return;
    
    if (error)
    {
        [self loadDidFinishWithError:error canceled:NO forceNewData:NO];
    }
    else if (operation == [_updateOperations lastObject])
    {
        if (_saveAfterLoad)
            [self performSave];
        else
            [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }    
}


#pragma mark - Protected methods


- (void)createWorkerContext
{
    [self freeWorkerContext];
    
    _workerContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
    
#if DEBUG
    NSString *workingName = [NSString stringWithFormat:@"%@ WORKER CONTEXT", _groupId];
    [_workerContext MR_setWorkingName:workingName];
    
#endif
}


- (void)freeWorkerContext
{
    if (_workerContext)
        [_workerContext reset];
    
    _workerContext = nil;
}


#pragma mark - Save


- (void)performSave
{
    __weak typeof(self) weakSelf = self;
    
    if ([_workerContext hasChanges])
    {
        if ([weakSelf cancelled]) return;
        
        [self setGroupLastUpdateDate];
        
        //saving worker context pushes changes to default context (main)
        [_workerContext MR_saveOnlySelfAndWait];

        //once data is in default it can be used for UI (main thread) and there is
        //no need to wait for it to be persisted
        [self loadDidFinishWithError:nil canceled:NO forceNewData:YES];
        
        //now write data to disk asynchronously without blocking UI
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];
    }
    else
    {
#if DEBUG
        NSLog(@"No need to save because there are no changes in context.");
#endif
        
        [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
}


#pragma mark - setGroupLastUpdateDate


- (void)setGroupLastUpdateDate
{
    [_workerContext performBlockAndWait:^{
        LGDataUpdateGroup *updateGroup = [LGDataUpdateGroup MR_findFirstByAttribute:@"groupId"
                                                                          withValue:_groupId
                                                                          inContext:_workerContext];
        
        if (!updateGroup)
        {
            updateGroup = [LGDataUpdateGroup MR_createInContext:_workerContext];
            updateGroup.groupId = _groupId;
        }
        
        updateGroup.updateDate = [NSDate date];
    }];
}


- (NSDate *)groupUpdateDate
{
    __block NSDate *updateDate;
    
    [_workerContext performBlockAndWait:^{
        LGDataUpdateGroup *updateGroup = [LGDataUpdateGroup MR_findFirstByAttribute:@"groupId"
                                                                          withValue:_groupId
                                                                          inContext:_workerContext];
        
        updateDate = updateGroup.updateDate;
    }];
    
    return updateDate;
}


- (BOOL)isGroupDataStale
{
    NSDate *updateDate = [self groupUpdateDate];
    
    return !updateDate || [(NSDate *)[updateDate dateByAddingTimeInterval:_cacheValidTime] compare:[NSDate date]] != NSOrderedDescending;
}


#pragma mark - Progress


- (void)showProgressForActivityView
{
    NSArray *huds = [MBProgressHUD allHUDsForView:_activityView];
    
    if (huds && [huds count] == 0)
    {
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:_activityView];
        hud.dimBackground = YES;
        [_activityView addSubview:hud];
        [hud show:YES];
    }
}


- (void)hideProgressForActivityView
{
    [MBProgressHUD hideAllHUDsForView:_activityView animated:YES];
}


#pragma mark -


@end

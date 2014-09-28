//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationManager.h"
#import <CoreData/CoreData.h>
#import "MBProgressHUD.h"


#define kStackedRequestsLastUpdateTimeFormat @"StackedRequestsLastUpdateTime.groupId.%@"


@implementation LGDataUpdateOperationManager


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
    _stackedRequestsSecondsToCache = 900;
    
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
    
    if ([self isStackedRequestsDataStale] || ignoreCacheInterval)
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
        NSDate *lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, _groupId]];
        
        NSTimeInterval lastUpdateInterval = [lastUpdateDate timeIntervalSinceReferenceDate];
        NSTimeInterval staleAtInterval = lastUpdateInterval + _stackedRequestsSecondsToCache;
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate];
        NSTimeInterval dataValidForInterval = staleAtInterval - currentTimeInterval;

#if DEBUG
        NSLog(@"Not updating because data is not stale. Stacked requests seconds to cache is set to %ld second(s). Last update was at %@ so data is valid for another %.0f second(s).", _stackedRequestsSecondsToCache, lastUpdateDate, dataValidForInterval);
#endif
        
        [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
}


- (void)cancelLoad
{
    if (![[NSThread currentThread] isMainThread])
    {
        [self performSelectorOnMainThread:@selector(cancelLoad) withObject:nil waitUntilDone:NO];
        return;
    }
    
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
        
        [_workerContext MR_saveWithOptions:MRSaveParentContexts | MRSaveSynchronouslyExceptRootContext completion:^(BOOL success, NSError *error) {
            [weakSelf saveStackedRequestsIDs];
            [weakSelf saveStackedRequestsLastUpdateTime];
            [weakSelf loadDidFinishWithError:nil canceled:NO forceNewData:YES];
        }];
    }
    else
    {
#if DEBUG
        NSLog(@"No need to save because there are no changes in context.");
#endif
        
        [self saveStackedRequestsLastUpdateTime];
        [self loadDidFinishWithError:nil canceled:NO forceNewData:NO];
    }
}


#pragma mark - saveStackedRequestsIDs


- (void)saveStackedRequestsIDs
{
    for (LGDataUpdateOperation *operation in _updateOperations)
    {
        NSString *requestIdentifier = operation.requestIdentifier;
        
        NSAssert(requestIdentifier, @"Request needs to have a key for caching.");
        
        NSString *responseFingerprint = operation.responseFingerprint;
        
        if (responseFingerprint)
        {
            [[NSUserDefaults standardUserDefaults] setObject:responseFingerprint forKey:requestIdentifier];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
#if DEBUG
            NSLog(@"Saved response fingerprint: '%@' for request with identifier: '%@'", responseFingerprint, requestIdentifier);
#endif
        }
        else
        {
#if DEBUG
            NSLog(@"No response fingerprint for request with url: '%@' and identifier: '%@'. Request needs to have a fingerprint (e.g. ETag or Last-Modified) for caching.", [operation.response.URL absoluteString], requestIdentifier);
#endif
        }
    }
}


#pragma mark - Last update time


- (void)saveStackedRequestsLastUpdateTime
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, _groupId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)isStackedRequestsDataStale
{
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kStackedRequestsLastUpdateTimeFormat, _groupId]];
    
    return !lastUpdate || [(NSDate *)[lastUpdate dateByAddingTimeInterval:_stackedRequestsSecondsToCache] compare:[NSDate date]] != NSOrderedDescending;
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

//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationDelegate.h"
#import "LGDataUpdateOperation.h"
#import <UIKit/UIKit.h>


@interface LGDataUpdateOperationGroupManager : NSObject <LGDataUpdateOperationDelegate>


@property (readonly, atomic) BOOL finished;
@property (readonly, atomic) BOOL running;
@property (readonly, atomic) BOOL cancelled;
@property (readonly, atomic) BOOL newData;
@property (readonly, atomic) NSError *error;

@property (readonly, nonatomic) NSString *groupId;

@property (assign, nonatomic) BOOL saveAfterLoad;
@property (assign, nonatomic) NSUInteger cacheValidTime;
@property (weak, nonatomic) UIView *activityView;


- (instancetype)initWithUpdateOperations:(NSArray *)updateOperations andGroupId:(NSString *)groupId;

- (void)updateDataIgnoringCacheIntervalWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (void)updateDataWithCompletionBlock:(void(^)(NSError *error, BOOL newData))completionBlock;
- (void)cancelLoad;


@end


#pragma mark - Protected


@interface LGDataUpdateOperationGroupManager ()


@property (copy, nonatomic) void(^updateCompletionBlock)(NSError *error, BOOL newData);
@property (strong, nonatomic) NSManagedObjectContext *workerContext;
@property (strong, nonatomic) NSArray *updateOperations;


- (void)createWorkerContext;
- (void)freeWorkerContext;
- (void)performSave;
- (void)setGroupLastUpdateDate;
- (BOOL)isGroupDataStale;


@end

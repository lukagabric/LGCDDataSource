//
//  LGDataUpdateOperation_Internal.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 13/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "LGDataUpdateOperation.h"
#import <CoreData/CoreData.h>
#import "LGDataUpdateInfo.h"

@interface LGDataUpdateOperation ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *bgContext;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) NSURLResponse *response;
@property (strong, nonatomic) NSData *responseData;
@property (readonly, nonatomic) id serializedResponseData;
@property (strong, nonatomic) id dataUpdateResult;
@property (readonly, nonatomic) NSString *responseFingerprint;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSString *requestId;
@property (strong, nonatomic) PMKPromise *promise;
@property (copy, nonatomic) PMKFulfiller fulfill;
@property (copy, nonatomic) PMKRejecter reject;
@property (copy, nonatomic) LGDataUpdate dataUpdate;
@property (strong, nonatomic) LGDataUpdateInfo *dataUpdateInfo;

- (id)parseData;
- (BOOL)isDataNew;
- (void)finishOperation;

@end

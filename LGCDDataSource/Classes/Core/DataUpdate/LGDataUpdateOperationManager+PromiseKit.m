//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationManager+PromiseKit.h"


@implementation LGDataUpdateOperationManager (PromiseKit)


- (PMKPromise *)dataUpdatePromise
{
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self updateDataWithCompletionBlock:^(NSError *error, BOOL newData) {
            if (error)
                reject(error);
            else
                fulfill(@(newData));
        }];
    }];
    
    return promise;
}


- (PMKPromise *)dataUpdateIgnoringCacheIntervalPromise
{
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self updateDataIgnoringCacheIntervalWithCompletionBlock:^(NSError *error, BOOL newData) {
            if (error)
                reject(error);
            else
                fulfill(@(newData));
        }];
    }];
    
    return promise;
}


@end

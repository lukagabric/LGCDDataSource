//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationGroupManager.h"
#import "PromiseKit.h"


@interface LGDataUpdateOperationGroupManager (PromiseKit)


- (PMKPromise *)dataUpdatePromise;
- (PMKPromise *)dataUpdateIgnoringCacheIntervalPromise;


@end

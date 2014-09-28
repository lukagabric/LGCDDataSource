//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperationManager.h"
#import "PromiseKit.h"


@interface LGDataUpdateOperationManager (PromiseKit)


- (PMKPromise *)dataUpdatePromise;
- (PMKPromise *)dataUpdateIgnoringCacheIntervalPromise;


@end

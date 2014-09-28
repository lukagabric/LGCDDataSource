//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#ifndef LCDDataSource_LDataUpdateOperationDelegate_h
#define LCDDataSource_LDataUpdateOperationDelegate_h


#import <Foundation/Foundation.h>


@class LGDataUpdateOperation;


@protocol LGDataUpdateOperationDelegate <NSObject>


- (void)operation:(LGDataUpdateOperation *)operation didFinishWithError:(NSError *)error;


@end


#endif

//
//  LGDataSource.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 13/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LGContextTransferable.h"
#import "PromiseKit.h"

typedef NS_ENUM(NSUInteger, LGContentWeight) {
    LGContentWeightStub,
    LGContentWeightLight,
    LGContentWeightHeavy,
};

typedef id(^LGDataUpdate)(id data, NSURLResponse *response, NSManagedObjectContext *context);

@interface LGDataSource : NSObject

- (instancetype)initWithSession:(NSURLSession *)session
                    mainContext:(NSManagedObjectContext *)mainContext NS_DESIGNATED_INITIALIZER;

- (PMKPromise *)updateDataPromiseWithRequest:(NSURLRequest *)request
                                   requestId:(NSString *)requestId
                               staleInterval:(NSTimeInterval)staleInterval
                                  dataUpdate:(LGDataUpdate)dataUpdate;

@end

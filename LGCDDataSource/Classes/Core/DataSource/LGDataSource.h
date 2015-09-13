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
#import "LGResponse.h"

typedef NS_ENUM(NSUInteger, LGContentWeight) {
    LGContentWeightStub,
    LGContentWeightLight,
    LGContentWeightHeavy,
};

typedef id(^LGDataUpdate)(id data, LGResponse *response, NSManagedObjectContext *context);

@interface LGDataSource : NSObject

- (instancetype)initWithSession:(NSURLSession *)session
                    mainContext:(NSManagedObjectContext *)mainContext NS_DESIGNATED_INITIALIZER;

- (PMKPromise *)updateDataPromiseWithUrl:(NSString *)url
                              methodName:(NSString *)methodName
                              parameters:(NSDictionary *)parameters
                               requestId:(NSString *)requestId
                           staleInterval:(NSTimeInterval)staleInterval
                              dataUpdate:(LGDataUpdate)dataUpdate;
@end

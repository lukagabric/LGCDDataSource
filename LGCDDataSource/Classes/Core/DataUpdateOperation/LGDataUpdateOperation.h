//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//

#import <PromiseKit.h>
#import "LGDataSource.h"

@interface LGDataUpdateOperation : NSOperation

- (instancetype)initWithSession:(NSURLSession *)session
                        request:(NSURLRequest *)request
                      requestId:(NSString *)requestId
                    mainContext:(NSManagedObjectContext *)mainContext
                      bgContext:(NSManagedObjectContext *)bgContext
                     dataUpdate:(LGDataUpdate)dataUpdate NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic) NSString *requestId;
@property (readonly, nonatomic) PMKPromise *promise;

@end

//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//

#import "PromiseKit.h"
#import "LGDataSource.h"

@interface LGDataDownloadOperation : NSOperation

- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic) PMKPromise *promise;

@end

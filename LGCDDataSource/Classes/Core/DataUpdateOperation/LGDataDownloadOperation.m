//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataDownloadOperation.h"
#import "LGResponse.h"
#import "PromiseKit.h"
#import <CoreData/CoreData.h>
#import "LGDataUpdateInfo.h"

@interface LGDataDownloadOperation ()

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (strong, nonatomic) PMKPromise *promise;
@property (copy, nonatomic) PMKFulfiller fulfill;
@property (copy, nonatomic) PMKRejecter reject;

@end

@implementation LGDataDownloadOperation {
    BOOL _finished;
    BOOL _executing;
}

#pragma mark - Init

- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        NSAssert(session && request, @"Dependencies are mandatory");
        
        self.session = session;
        
        __weak id weakSelf = self;
        self.promise = [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
            LGDataDownloadOperation *strongSelf = weakSelf;
            if (!strongSelf) return;

            strongSelf.fulfill = fulfill;
            strongSelf.reject = reject;
        }];
        
        self.task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LGDataDownloadOperation *strongSelf = weakSelf;
                if (!strongSelf) return;
                
                LGResponse *resp = [[LGResponse alloc] initWithHTTPResponse:(NSHTTPURLResponse *)response andResponseData:data];
                [strongSelf taskDidFinishWithResponse:resp error:error];
            });
        }];
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc {
#if DEBUG
    NSLog(@"%@ dealloc", [self class]);
#endif
}

#pragma mark - NSOperation

- (void)start {
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self.task resume];
}

- (void)taskDidFinishWithResponse:(LGResponse *)response error:(NSError *)error {
    NSAssert([NSThread isMainThread], @"Must be executed on main thread");
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    
    if (error) {
        self.reject(error);
    }
    else {
        self.fulfill(response);
    }
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)cancel {
    [self.task cancel];
    [super cancel];
}

#pragma mark -

@end

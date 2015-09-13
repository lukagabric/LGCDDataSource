//
//  LGResponse.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 13/09/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "LGResponse.h"

@interface LGResponse ()

@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;
@property (strong, nonatomic) NSData *responseData;

@end

@implementation LGResponse

- (instancetype)initWithHTTPResponse:(NSHTTPURLResponse *)httpResponse andResponseData:(NSData *)responseData {
    self = [super init];
    if (self) {
        self.httpResponse = httpResponse;
        self.responseData = responseData;
    }
    return self;
}

@end

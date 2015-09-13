//
//  LGResponse.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 13/09/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LGResponse : NSObject

- (instancetype)initWithHTTPResponse:(NSHTTPURLResponse *)httpResponse andResponseData:(NSData *)responseData NS_DESIGNATED_INITIALIZER;

@property (readonly, nonatomic) NSHTTPURLResponse *httpResponse;
@property (readonly, nonatomic) NSData *responseData;

@property (readonly, nonatomic) NSString *etag;
@property (readonly, nonatomic) NSString *lastModified;
@property (readonly, nonatomic) NSInteger statusCode;

@end

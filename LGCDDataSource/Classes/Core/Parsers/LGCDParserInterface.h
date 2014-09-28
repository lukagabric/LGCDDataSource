//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@protocol LGCDParserInterface <NSObject>


- (void)parseData:(NSData *)data;
- (void)setResponse:(NSURLResponse *)response;
- (NSError *)error;
- (NSSet *)itemsSet;
- (void)abortParsing;
- (void)setContext:(NSManagedObjectContext *)context;


@end
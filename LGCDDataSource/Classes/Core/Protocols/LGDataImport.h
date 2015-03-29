//
//  LGDataImport.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 29/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LGDataImport <NSObject>

+ (NSDictionary *)dataUpdateMappings;
+ (NSDateFormatter *)dateFormatter;
+ (NSDate *)dateFromString:(NSString *)dateString;

@end

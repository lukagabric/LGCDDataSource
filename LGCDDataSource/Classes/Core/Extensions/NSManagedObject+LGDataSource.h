//
//  NSManagedObject+LGDataSource.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 29/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (LGDataSource)

+ (NSDictionary *)lg_dataUpdateMappings;
+ (NSDateFormatter *)lg_dateFormatter;
+ (NSDate *)lg_dateFromString:(NSString *)dateString;

- (id)lg_transformedRawValue:(id)rawValue forKey:(NSString *)key;
- (void)lg_mergeWithDictionary:(NSDictionary *)dictionary;

@end

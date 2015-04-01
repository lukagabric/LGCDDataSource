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
+ (NSDate *)lg_dateForKey:(NSString *)key fromString:(NSString *)dateString;
+ (NSString *)entityName;
+ (NSArray *)existingObjectsOrStubsWithGuids:(NSString *)guids
                                     guidKey:(NSString *)guidKey
                                   inContext:(NSManagedObjectContext *)context;

- (id)lg_transformedRawValue:(id)rawValue forKey:(NSString *)key withAttributes:(NSDictionary *)attributes;
- (void)lg_mergeWithDictionary:(NSDictionary *)dictionary;
- (BOOL)lg_isUpdateDataValid:(NSDictionary *)updateData;

@end

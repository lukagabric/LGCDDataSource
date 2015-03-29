//
//  NSManagedObject+LGDataSource.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 29/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "NSManagedObject+LGDataSource.h"

@implementation NSManagedObject (LGDataSource)

- (void)mergeObjectWithDictionary:(NSDictionary *)dictionary {
    NSDictionary *mappings = [[self class] dataUpdateMappings];
    
    if (!mappings) return;
    
    for (NSString *dictKey in dictionary) {
        NSString *attributeKey = mappings[dictKey];
        if (!attributeKey) continue;
        
        id rawValue = dictionary[dictKey];
        if (rawValue == [NSNull null]) continue;
        
        id value = [self transformedRawValue:rawValue forKey:attributeKey];
        [self setValue:value forKey:attributeKey];
    }
}

- (id)transformedRawValue:(id)rawValue forKey:(NSString *)key {
    NSDictionary *attributes = self.entity.attributesByName;

    NSAttributeDescription *attributeDescription = [attributes valueForKey:key];
    NSAttributeType attributeType = attributeDescription.attributeType;

    id value = rawValue;
    
    if ([rawValue isKindOfClass:[NSString class]]) {
        if (attributeType == NSDateAttributeType) {
            value = [[self class] dateFromString:rawValue];
        }
        else if (attributeType == NSInteger16AttributeType ||
                 attributeType == NSInteger32AttributeType ||
                 attributeType == NSInteger64AttributeType ||
                 attributeType == NSDecimalAttributeType ||
                 attributeType == NSDoubleAttributeType ||
                 attributeType == NSFloatAttributeType) {
            rawValue = [NSNumber numberWithDouble:[value doubleValue]];
        }
    }
    
    return value;
}

#pragma mark - LGDataImport

+ (NSDictionary *)dataUpdateMappings {
    return nil;
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    }
    
    return dateFormatter;
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *formatter = [self dateFormatter];
    return [formatter dateFromString:dateString];
}

#pragma mark -

@end

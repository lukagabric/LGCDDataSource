//
//  NSManagedObject+LGDataSource.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 29/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "NSManagedObject+LGDataSource.h"
#import "NSArray+LGDataSource.h"

@implementation NSManagedObject (LGDataSource)

#pragma mark - LGContextTransferable

- (id)transferredToContext:(NSManagedObjectContext *)context {
    return [context objectWithID:self.objectID];
}

#pragma mark - Parsing

- (void)lg_mergeWithDictionary:(NSDictionary *)dictionary {
    if (![self lg_isUpdateDataValid:dictionary]) return;
    
    NSDictionary *mappings = [[self class] lg_dataUpdateMappings];
    
    if (!mappings) return;
    
    NSDictionary *attributes = self.entity.attributesByName;

    for (NSString *dictKey in dictionary) {
        NSString *attributeKey = mappings[dictKey];
        if (!attributeKey) continue;
        
        id rawValue = dictionary[dictKey];
        if (rawValue == [NSNull null]) continue;
        
        id value = [self lg_transformedRawValue:rawValue forKey:attributeKey withAttributes:attributes];
        if (value) {
            [self setValue:value forKey:attributeKey];
        }
    }
}

- (BOOL)lg_isUpdateDataValid:(NSDictionary *)updateData {
    return YES;
}

- (id)lg_transformedRawValue:(id)rawValue forKey:(NSString *)key withAttributes:(NSDictionary *)attributes {
    NSAttributeDescription *attributeDescription = [attributes valueForKey:key];
    NSAttributeType attributeType = attributeDescription.attributeType;

    id value = rawValue;
    
    if ([rawValue isKindOfClass:[NSString class]]) {
        if (attributeType == NSDateAttributeType) {
            value = [[[self class] lg_dateFormatter] dateFromString:rawValue];
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

+ (NSDictionary *)lg_dataUpdateMappings {
    return nil;
}

+ (NSDateFormatter *)lg_dateFormatter {
    static NSDateFormatter *dateFormatter;
    
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
    }
    
    return dateFormatter;
}

+ (NSString *)entityName {
    return nil;
}

+ (NSArray *)existingObjectsOrStubsWithGuids:(NSArray *)guids
                                     guidKey:(NSString *)guidKey
                                   inContext:(NSManagedObjectContext *)context {
    NSString *entityName = [self entityName];
    NSAssert(entityName != nil, @"Entity name must be provided");
    if (!entityName) return nil;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", guidKey, guids];
    
    NSError *error;
    NSArray *existingObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (error) return nil;
    
    NSArray *existingObjectsGuids = [existingObjects valueForKey:guidKey];
    
    NSMutableArray *newObjectsGuids = [guids mutableCopy];
    [newObjectsGuids removeObjectsInArray:existingObjectsGuids];
    
    NSMutableArray *results = [NSMutableArray arrayWithArray:existingObjects];

    for (NSString *guid in newObjectsGuids) {
        NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
        [newObject setValue:guid forKey:guidKey];
        [results addObject:newObject];
    }
    
    return [results count] > 0 ? results : nil;
}

+ (NSArray *)objectsWithData:(NSArray *)data
                 dataGuidKey:(NSString *)dataGuidKey
               objectGuidKey:(NSString *)objectGuidKey
                      weight:(LGContentWeight)weight
                     context:(NSManagedObjectContext *)context {
    NSArray *objects = [self existingObjectsOrStubsWithGuids:[data valueForKey:dataGuidKey]
                                                     guidKey:objectGuidKey
                                                   inContext:context];
    
    NSDictionary *objectsById = [objects lg_indexedByKeyPath:objectGuidKey];
    
    for (NSDictionary *dictionary in data) {
        NSString *guid = dictionary[@"id"];
        NSManagedObject *object = objectsById[guid];
        [object setValue:@(weight) forKey:@"weight"];
        [object lg_mergeWithDictionary:dictionary];
    }
    
    return objects;
}

#pragma mark -

@end

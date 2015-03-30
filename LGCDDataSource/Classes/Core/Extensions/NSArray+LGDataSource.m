//
//  NSArray+LGDataSource.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 29/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "NSArray+LGDataSource.h"

@implementation NSArray (LGDataSource)

#pragma mark - LGContextTransferable

- (id)transferredToContext:(NSManagedObjectContext *)context {
    NSMutableArray *transferredObjects = [NSMutableArray new];
    
    for (NSManagedObject *mo in self) {
        NSAssert([mo isKindOfClass:[NSManagedObject class]], @"Must be managed object");
        [mo.managedObjectContext performBlockAndWait:^{
            NSManagedObjectID *objectID = mo.objectID;
            
            [context performBlockAndWait:^{
                [transferredObjects addObject:[context objectWithID:objectID]];
            }];
        }];
    }
    
    return transferredObjects;
}

#pragma mark - Indexed Array

- (NSMutableDictionary *)lg_indexedByKeyPath:(NSString *)keyPath {
    NSMutableDictionary *indexedDictionary = [NSMutableDictionary new];
    
    for (id object in self) {
        if (object == [NSNull null]) continue;
        
        id key = [object valueForKeyPath:keyPath];
        
        if (key) {
            [indexedDictionary setValue:object forKey:key];
        }
    }
    
    return indexedDictionary;
}

#pragma mark -

@end

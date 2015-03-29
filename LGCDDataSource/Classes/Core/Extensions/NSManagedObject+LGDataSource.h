//
//  NSManagedObject+LGDataSource.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 29/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "LGDataImport.h"

@interface NSManagedObject (LGDataSource) <LGDataImport>

- (void)mergeObjectWithDictionary:(NSDictionary *)dictionary;

@end

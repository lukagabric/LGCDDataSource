//
//  LGContextTransferable.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 15/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol LGContextTransferable <NSObject>

- (id)transferredToContext:(NSManagedObjectContext *)context;

@end

//
//  ContactsInteractor.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 16/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LGDataSource.h"

@interface ContactsInteractor : NSObject

- (instancetype)initWithDataSource:(LGDataSource *)dataSource NS_DESIGNATED_INITIALIZER;

- (NSFetchedResultsController *)contactsWithUpdatePromise:(PMKPromise **)promise;

@end

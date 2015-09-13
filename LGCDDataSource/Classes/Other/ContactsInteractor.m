//
//  ContactsInteractor.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 16/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "ContactsInteractor.h"
#import "CoreData+MagicalRecord.h"
#import "Contact.h"

@interface ContactsInteractor ()

@property (strong, nonatomic) LGDataSource *dataSource;

@end

@implementation ContactsInteractor

- (instancetype)initWithDataSource:(LGDataSource *)dataSource {
    self = [super init];
    if (self) {
        self.dataSource = dataSource;
    }
    return self;
}

- (NSFetchedResultsController *)contactsWithUpdatePromise:(PMKPromise **)promise {
    *promise = [self.dataSource updateDataPromiseWithUrl:@"http://lukagabric.com/wp-content/contacts-api/contacts"
                                              methodName:@"GET"
                                              parameters:nil
                                               requestId:@"ContactsJSON"
                                           staleInterval:10
                                              dataUpdate:^id(NSArray *data, LGResponse *response, NSManagedObjectContext *context) {
                                                  return [Contact parseHeavyContactsData:data inContext:context];
                                              }];
    return [Contact MR_fetchAllSortedBy:@"lastName"
                              ascending:YES
                          withPredicate:nil
                                groupBy:nil
                               delegate:nil];
}

@end

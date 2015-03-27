//
//  ContactsInteractor.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 16/03/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

#import "ContactsInteractor.h"

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
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"]];
    *promise = [self.dataSource updateDataPromiseWithRequest:request
                                                   requestId:@"ContactsJSON"
                                               staleInterval:10
                                                  dataUpdate:^id(NSData *data, NSURLResponse *response, NSManagedObjectContext *context) {
                                                      return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                  }];
    return nil;
}

@end

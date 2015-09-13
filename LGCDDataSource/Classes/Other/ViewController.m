//
//  ViewController.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 27/09/14.
//  Copyright (c) 2014 Luka Gabric. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) ContactsInteractor *interactor;
@property (strong, nonatomic) NSFetchedResultsController *contactsFrc;

@end

@implementation ViewController

- (instancetype)initWithInteractor:(ContactsInteractor *)interactor {
    self = [super init];
    if (self) {
        self.interactor = interactor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PMKPromise *updatePromise;
    self.contactsFrc = [self.interactor contactsWithUpdatePromise:&updatePromise];
    self.contactsFrc.delegate = self;
    
    [self logContactsCount];
    
    if (updatePromise) {
        updatePromise.then(^(id result) {
            if ([result isKindOfClass:[NSDate class]]) {
                NSLog(@"Last refreshed at: %@", result);
            }
            else if ([result isKindOfClass:[NSArray class]]) {
                NSArray *results = result;
                NSLog(@"Updated items, count = %ld", results.count);
            }
        });
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self logContactsCount];
}

- (void)logContactsCount {
    NSLog(@"Contacts count: %ld", self.contactsFrc.fetchedObjects.count);
}

@end

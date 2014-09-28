//
//  ViewController.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 27/09/14.
//  Copyright (c) 2014 Luka Gabric. All rights reserved.
//


#import "ViewController.h"
#import "CoreData+MagicalRecord.h"
#import "DataSourceFactory.h"
#import "Contact.h"
#import "LGDataUpdateOperationManager+PromiseKit.h"


@implementation ViewController
{
    LGDataUpdateOperationGroupManager *_updateManager;
    LGDataUpdateOperationGroupManager *_updateManagerPromise;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    if (_updateManager)
        [_updateManager cancelLoad];

    _updateManager = [DataSourceFactory contactsUpdateManagerWithActivityView:self.view];

    [_updateManager updateDataIgnoringCacheIntervalWithCompletionBlock:^(NSError *error, BOOL newData) {
        NSLog(@"_updateManager: Data %@new", newData ? @"" : @"NOT ");
        NSLog(@"_updateManager: Contacts count = %ld", [Contact MR_countOfEntities]);
    }];
    
    
    if (_updateManagerPromise)
        [_updateManagerPromise cancelLoad];
    
    _updateManagerPromise = [DataSourceFactory contactsUpdateManagerWithActivityView:self.view];
    
    [_updateManagerPromise dataUpdateIgnoringCacheIntervalPromise].then(^(NSNumber *newData) {
        NSLog(@"_updateManagerPromise: Data %@new", [newData isEqualToNumber:@YES] ? @"" : @"NOT ");
        NSLog(@"_updateManagerPromise: Contacts count = %ld", [Contact MR_countOfEntities]);
    });
}


@end

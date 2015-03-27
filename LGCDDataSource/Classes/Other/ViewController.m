//
//  ViewController.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 27/09/14.
//  Copyright (c) 2014 Luka Gabric. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) ContactsInteractor *interactor;

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
    [self.interactor contactsWithUpdatePromise:&updatePromise];
    
    if (updatePromise) {
        updatePromise.then(^(id result) {
            NSLog(@"%@", result);
        });
    }
}

@end

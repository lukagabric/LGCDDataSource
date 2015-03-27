//
//  ViewController.h
//  LGCDDataSource
//
//  Created by Luka Gabric on 27/09/14.
//  Copyright (c) 2014 Luka Gabric. All rights reserved.
//

#import "ContactsInteractor.h"

@interface ViewController : UIViewController

- (instancetype)initWithInteractor:(ContactsInteractor *)interactor NS_DESIGNATED_INITIALIZER;

@end


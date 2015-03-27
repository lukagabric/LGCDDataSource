//
//  AppDelegate.m
//  LGCDDataSource
//
//  Created by Luka Gabric on 27/09/14.
//  Copyright (c) 2014 Luka Gabric. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CoreData+MagicalRecord.h"
#import "ContactsInteractor.h"
#import "LGDataUpdateInfo.h"

@implementation AppDelegate

/*
 - (void)deleteOrphanedObjectsWithParser:(id <LGCDParserInterface>)parser
 {
 NSSet *items = [parser itemsSet];
 
 NSString *entityName = [[[items anyObject] entity] name];
 
 if (!entityName || [entityName length] == 0) return;
 
 NSFetchRequest *fetchRequest = [NSFetchRequest new];
 
 fetchRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_workerContext];
 fetchRequest.includesPropertyValues = NO;
 
 NSError *error = nil;
 
 NSArray *allObjects = [self.bgContext executeFetchRequest:centerRequest error:&error];
 
 if (error)
 return;
 
 if ([allObjects count] > 0)
 {
 NSMutableSet *setToDelete = [NSMutableSet setWithArray:allObjects];
 
 [setToDelete minusSet:items];
 
 for (NSManagedObject *managedObjectToDelete in setToDelete)
 {
 [_workerContext deleteObject:managedObjectToDelete];
 
 #if DEBUG
 NSLog(@"deleted object - %@", managedObjectToDelete);
 #endif
 }
 }
 }
 */


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"LGModel"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSManagedObjectContext *mainContext = [NSManagedObjectContext MR_defaultContext];
    
    self.dataSource = [[LGDataSource alloc] initWithSession:session mainContext:mainContext];
    ContactsInteractor *contactsInteractor = [[ContactsInteractor alloc] initWithDataSource:self.dataSource];
    ViewController *viewController = [[ViewController alloc] initWithInteractor:contactsInteractor];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

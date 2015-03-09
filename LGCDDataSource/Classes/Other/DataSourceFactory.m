//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "DataSourceFactory.h"
#import "ContactsXMLParser.h"
#import "ContactsJSONParser.h"


@implementation DataSourceFactory


#define JSON 0


#if JSON
+ (LGDataUpdateOperation *)contactsUpdateOperation
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"]];
    return [[LGDataUpdateOperation alloc] initWithSession:[NSURLSession sharedSession]
                                                  request:request
                                                requestId:@"ContactsJSON"
                                                andParser:[ContactsJSONParser new]];
}

#else

+ (LGDataUpdateOperation *)contactsUpdateOperation
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.xml"]];
    return [[LGDataUpdateOperation alloc] initWithSession:[NSURLSession sharedSession]
                                                  request:request
                                                requestId:@"ContactsXML"
                                                andParser:[ContactsXMLParser new]];
}
#endif


+ (LGDataUpdateOperationGroupManager *)contactsUpdateManagerWithActivityView:(UIView *)activityView
{
    LGDataUpdateOperationGroupManager *contactsDataManager = [[LGDataUpdateOperationGroupManager alloc] initWithUpdateOperations:@[[self contactsUpdateOperation]] andGroupId:@"contacts"];
    contactsDataManager.activityView = activityView;
    
    return contactsDataManager;
}


@end
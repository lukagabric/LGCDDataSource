//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "DataSourceFactory.h"
#import "ContactsXMLParser.h"
#import "ContactsJSONParser.h"


@implementation DataSourceFactory


#define JSON 1


#if JSON
+ (LGDataUpdateOperation *)contactsUpdateOperation
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.json"]];
    return [[LGDataUpdateOperation alloc] initWithSession:[NSURLSession sharedSession]
                                                 request:request
                                       requestIdentifier:@"ContactsJSON"
                                               andParser:[ContactsJSONParser new]];
}

#else

+ (LDataUpdateOperation *)contactsUpdateOperation
{
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://lukagabric.com/wp-content/uploads/2014/03/contacts.xml"]];
    return [[LDataUpdateOperation alloc] initWithSession:[NSURLSession sharedSession]
                                                 request:request
                                       requestIdentifier:@"ContactsXML"
                                               andParser:[ContactsParser new]];
}
#endif


+ (LGDataUpdateOperationManager *)contactsUpdateManagerWithActivityView:(UIView *)activityView
{
    LGDataUpdateOperationManager *contactsDataManager = [[LGDataUpdateOperationManager alloc] initWithUpdateOperations:@[[self contactsUpdateOperation]] andGroupId:@"contacts"];
    contactsDataManager.activityView = activityView;
    
    return contactsDataManager;
}


@end
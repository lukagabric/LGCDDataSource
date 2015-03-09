//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "ContactsXMLParser.h"
#import "CoreData+MagicalRecord.h"
#import "Contact.h"


@implementation ContactsXMLParser
{
    Contact *_contact;
}


- (void)didStartElement
{
    ifElement(@"contact") _contact = [Contact MR_createInContext:_context];
;
}


- (void)didEndElement
{
    ifElement(@"contact") [_itemsSet addObject:_contact];
    elifElement(@"firstName") bindStr(_contact.firstName);
    elifElement(@"lastName")
    {
        bindStr(_contact.lastName);
        _contact.lastNameInitial = [_contact.lastName substringToIndex:1];
    }
    elifElement(@"email") bindStr(_contact.email);
    elifElement(@"company") bindStr(_contact.company);
}


- (NSString *)entityName
{
    return @"Contact";
}


@end
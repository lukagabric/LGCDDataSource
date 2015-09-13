#import "Contact.h"
#import "NSManagedObject+LGDataSource.h"
#import "CoreData+MagicalRecord.h"
#import "LGDataSource.h"
#import "NSArray+LGDataSource.h"

@interface Contact ()

@end

@implementation Contact

#pragma mark - Parsing

+ (NSArray *)parseHeavyContactsData:(NSArray *)data inContext:(NSManagedObjectContext *)context {
    /*
    NSArray *contacts = [self objectsWithData:data
                                  dataGuidKey:@"id"
                                objectGuidKey:@"guid"
                                       weight:LGContentWeightHeavy
                                      context:context];
    
    return contacts;
     */
    
    NSArray *contacts = [self existingObjectsOrStubsWithGuids:[data valueForKey:@"id"]
                                                      guidKey:@"guid"
                                                    inContext:context];
    
    NSDictionary *contactsById = [contacts lg_indexedByKeyPath:@"guid"];
    
    for (NSDictionary *dictionary in data) {
        NSString *guid = dictionary[@"id"];
        Contact *contact = contactsById[guid];
        contact.weightValue = LGContentWeightHeavy;
        [contact lg_mergeWithDictionary:dictionary];
        [self processRelatedContactGuids:dictionary[@"relatedContacts"]
                              forContact:contact
                               inContext:context];
    }
    
    return contacts;
}

+ (NSArray *)processRelatedContactGuids:(NSArray *)relatedContactGuids forContact:(Contact *)contact inContext:(NSManagedObjectContext *)context {
    if (!relatedContactGuids) return nil;
    
    NSArray *relatedContacts = [self existingObjectsOrStubsWithGuids:relatedContactGuids
                                                             guidKey:@"guid"
                                                           inContext:context];
    if (relatedContacts) {
        [contact addChildContacts:[NSSet setWithArray:relatedContacts]];
    }
    
    return relatedContactGuids;
}

#pragma mark - Mappings

+ (NSDictionary *)lg_dataUpdateMappings {
    static NSDictionary *mappings;
    
    if (!mappings) {
        mappings = @{@"id": @"guid",
                     @"firstName": @"firstName",
                     @"lastName": @"lastName",
                     @"email": @"email",
                     @"company": @"company"};
    }
    
    return mappings;
}

#pragma mark -

@end

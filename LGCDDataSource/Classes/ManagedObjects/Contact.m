#import "Contact.h"
#import "NSManagedObject+LGDataSource.h"
#import <CoreData+MagicalRecord.h>
#import "LGDataSource.h"

@interface Contact ()

@end

@implementation Contact

#pragma mark - Parsing

+ (NSMutableDictionary *)array:(NSArray *)array indexedByKeyPath:(NSString *)keyPath {
    NSMutableDictionary *indexedDictionary = [NSMutableDictionary new];
    
    for (id object in array) {
        if (object == [NSNull null]) continue;
        [indexedDictionary setValue:object forKey:[object valueForKeyPath:keyPath]];
    }
    
    return indexedDictionary;
}

+ (NSArray *)parseHeavyContactsData:(NSArray *)data inContext:(NSManagedObjectContext *)context {
    NSArray *dataContactIds = [data valueForKey:@"id"];

    NSArray *existingContacts = [Contact MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(guid IN %@)", dataContactIds] inContext:context];
    NSArray *existingContactIds = [existingContacts valueForKey:@"guid"];

    NSMutableArray *newContactIds = [dataContactIds mutableCopy];
    [newContactIds removeObjectsInArray:existingContactIds];
    
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:existingContacts];

    for (NSString *contactId in newContactIds) {
        Contact *newContact = [Contact insertInManagedObjectContext:context];
        newContact.guid = contactId;
        [contacts addObject:newContact];
    }
    
    NSDictionary *contactsById = [self array:contacts indexedByKeyPath:@"guid"];
    
    for (NSDictionary *dictionary in data) {
        NSString *guid = dictionary[@"id"];
        Contact *contact = contactsById[guid];
        contact.weightValue = LGContentWeightHeavy;
        [contact mergeObjectWithDictionary:dictionary];
    }
    
    return contacts;
}

#pragma mark - LGDataImport

+ (NSDictionary *)dataUpdateMappings {
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

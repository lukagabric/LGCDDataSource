#import "Contact.h"
#import "NSManagedObject+LGDataSource.h"
#import <CoreData+MagicalRecord.h>
#import "LGDataSource.h"
#import "NSArray+LGDataSource.h"

@interface Contact ()

@end

@implementation Contact

#pragma mark - Parsing

+ (NSArray *)parseHeavyContactsData:(NSArray *)data inContext:(NSManagedObjectContext *)context {
    NSArray *contacts = [self existingObjectsOrStubsWithGuids:[data valueForKey:@"id"]
                                                      guidKey:@"guid"
                                                    inContext:context];
    
    NSDictionary *contactsById = [contacts lg_indexedByKeyPath:@"guid"];
    
    for (NSDictionary *dictionary in data) {
        NSString *guid = dictionary[@"id"];
        Contact *contact = contactsById[guid];
        contact.weightValue = LGContentWeightHeavy;
        [contact lg_mergeWithDictionary:dictionary];
    }
    
    return contacts;
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

#import "Contact.h"
#import "NSManagedObject+LGDataSource.h"
#import <CoreData+MagicalRecord.h>

@interface Contact ()

@end

@implementation Contact

#pragma mark - Parsing

+ (NSArray *)parseHeavyContactsData:(NSArray *)data inContext:(NSManagedObjectContext *)context {
    NSMutableArray *contacts = [NSMutableArray new];
    
    //implement efficient find or create pattern
    
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

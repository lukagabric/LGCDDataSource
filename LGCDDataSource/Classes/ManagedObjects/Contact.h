#import "_Contact.h"

@interface Contact : _Contact {}

+ (NSArray *)parseHeavyContactsData:(NSArray *)data inContext:(NSManagedObjectContext *)context;

@end

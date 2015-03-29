#import "_Contact.h"
#import "LGDataImport.h"

@interface Contact : _Contact <LGDataImport> {}

+ (NSArray *)parseHeavyContactsData:(NSArray *)data inContext:(NSManagedObjectContext *)context;

@end

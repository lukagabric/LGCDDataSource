// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Contact.m instead.

#import "_Contact.h"

const struct ContactAttributes ContactAttributes = {
	.company = @"company",
	.email = @"email",
	.firstName = @"firstName",
	.lastName = @"lastName",
	.lastNameInitial = @"lastNameInitial",
};

const struct ContactRelationships ContactRelationships = {
};

const struct ContactFetchedProperties ContactFetchedProperties = {
};

@implementation ContactID
@end

@implementation _Contact

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Contact";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Contact" inManagedObjectContext:moc_];
}

- (ContactID*)objectID {
	return (ContactID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic company;






@dynamic email;






@dynamic firstName;






@dynamic lastName;






@dynamic lastNameInitial;











@end

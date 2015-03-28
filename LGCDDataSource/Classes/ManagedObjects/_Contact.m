// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Contact.m instead.

#import "_Contact.h"

const struct ContactAttributes ContactAttributes = {
	.company = @"company",
	.email = @"email",
	.firstName = @"firstName",
	.guid = @"guid",
	.lastName = @"lastName",
	.weight = @"weight",
};

const struct ContactRelationships ContactRelationships = {
	.childContacts = @"childContacts",
	.parentContact = @"parentContact",
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
	
	if ([key isEqualToString:@"weightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"weight"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic company;






@dynamic email;






@dynamic firstName;






@dynamic guid;






@dynamic lastName;






@dynamic weight;



- (int16_t)weightValue {
	NSNumber *result = [self weight];
	return [result shortValue];
}

- (void)setWeightValue:(int16_t)value_ {
	[self setWeight:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveWeightValue {
	NSNumber *result = [self primitiveWeight];
	return [result shortValue];
}

- (void)setPrimitiveWeightValue:(int16_t)value_ {
	[self setPrimitiveWeight:[NSNumber numberWithShort:value_]];
}





@dynamic childContacts;

	
- (NSMutableSet*)childContactsSet {
	[self willAccessValueForKey:@"childContacts"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"childContacts"];
  
	[self didAccessValueForKey:@"childContacts"];
	return result;
}
	

@dynamic parentContact;

	






@end

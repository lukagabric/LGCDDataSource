// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LGDataUpdateRequest.m instead.

#import "_LGDataUpdateRequest.h"

const struct LGDataUpdateRequestAttributes LGDataUpdateRequestAttributes = {
	.requestId = @"requestId",
	.responseFingerprint = @"responseFingerprint",
	.updateDate = @"updateDate",
};

const struct LGDataUpdateRequestRelationships LGDataUpdateRequestRelationships = {
};

const struct LGDataUpdateRequestFetchedProperties LGDataUpdateRequestFetchedProperties = {
};

@implementation LGDataUpdateRequestID
@end

@implementation _LGDataUpdateRequest

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LGDataUpdateRequest" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LGDataUpdateRequest";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LGDataUpdateRequest" inManagedObjectContext:moc_];
}

- (LGDataUpdateRequestID*)objectID {
	return (LGDataUpdateRequestID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic requestId;






@dynamic responseFingerprint;






@dynamic updateDate;











@end

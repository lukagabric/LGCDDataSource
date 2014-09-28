// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LGDataUpdateGroup.m instead.

#import "_LGDataUpdateGroup.h"

const struct LGDataUpdateGroupAttributes LGDataUpdateGroupAttributes = {
	.groupId = @"groupId",
	.updateDate = @"updateDate",
};

const struct LGDataUpdateGroupRelationships LGDataUpdateGroupRelationships = {
};

const struct LGDataUpdateGroupFetchedProperties LGDataUpdateGroupFetchedProperties = {
};

@implementation LGDataUpdateGroupID
@end

@implementation _LGDataUpdateGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LGDataUpdateGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LGDataUpdateGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LGDataUpdateGroup" inManagedObjectContext:moc_];
}

- (LGDataUpdateGroupID*)objectID {
	return (LGDataUpdateGroupID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic groupId;






@dynamic updateDate;











@end

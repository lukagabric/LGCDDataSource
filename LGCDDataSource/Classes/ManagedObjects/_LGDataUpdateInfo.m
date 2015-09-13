// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LGDataUpdateInfo.m instead.

#import "_LGDataUpdateInfo.h"

const struct LGDataUpdateInfoAttributes LGDataUpdateInfoAttributes = {
	.etag = @"etag",
	.lastModified = @"lastModified",
	.lastUpdateDate = @"lastUpdateDate",
	.requestId = @"requestId",
};

const struct LGDataUpdateInfoRelationships LGDataUpdateInfoRelationships = {
};

const struct LGDataUpdateInfoFetchedProperties LGDataUpdateInfoFetchedProperties = {
};

@implementation LGDataUpdateInfoID
@end

@implementation _LGDataUpdateInfo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LGDataUpdateInfo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LGDataUpdateInfo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LGDataUpdateInfo" inManagedObjectContext:moc_];
}

- (LGDataUpdateInfoID*)objectID {
	return (LGDataUpdateInfoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic etag;






@dynamic lastModified;






@dynamic lastUpdateDate;






@dynamic requestId;











@end

// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LGDataUpdateGroup.h instead.

#import <CoreData/CoreData.h>


extern const struct LGDataUpdateGroupAttributes {
	__unsafe_unretained NSString *groupId;
	__unsafe_unretained NSString *updateDate;
} LGDataUpdateGroupAttributes;

extern const struct LGDataUpdateGroupRelationships {
} LGDataUpdateGroupRelationships;

extern const struct LGDataUpdateGroupFetchedProperties {
} LGDataUpdateGroupFetchedProperties;





@interface LGDataUpdateGroupID : NSManagedObjectID {}
@end

@interface _LGDataUpdateGroup : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LGDataUpdateGroupID*)objectID;





@property (nonatomic, strong) NSString* groupId;



//- (BOOL)validateGroupId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updateDate;



//- (BOOL)validateUpdateDate:(id*)value_ error:(NSError**)error_;






@end

@interface _LGDataUpdateGroup (CoreDataGeneratedAccessors)

@end

@interface _LGDataUpdateGroup (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveGroupId;
- (void)setPrimitiveGroupId:(NSString*)value;




- (NSDate*)primitiveUpdateDate;
- (void)setPrimitiveUpdateDate:(NSDate*)value;




@end

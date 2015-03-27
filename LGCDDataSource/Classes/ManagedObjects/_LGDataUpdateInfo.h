// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LGDataUpdateInfo.h instead.

#import <CoreData/CoreData.h>


extern const struct LGDataUpdateInfoAttributes {
	__unsafe_unretained NSString *lastUpdateDate;
	__unsafe_unretained NSString *requestId;
	__unsafe_unretained NSString *responseFingerprint;
} LGDataUpdateInfoAttributes;

extern const struct LGDataUpdateInfoRelationships {
} LGDataUpdateInfoRelationships;

extern const struct LGDataUpdateInfoFetchedProperties {
} LGDataUpdateInfoFetchedProperties;






@interface LGDataUpdateInfoID : NSManagedObjectID {}
@end

@interface _LGDataUpdateInfo : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LGDataUpdateInfoID*)objectID;





@property (nonatomic, strong) NSDate* lastUpdateDate;



//- (BOOL)validateLastUpdateDate:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* requestId;



//- (BOOL)validateRequestId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* responseFingerprint;



//- (BOOL)validateResponseFingerprint:(id*)value_ error:(NSError**)error_;






@end

@interface _LGDataUpdateInfo (CoreDataGeneratedAccessors)

@end

@interface _LGDataUpdateInfo (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveLastUpdateDate;
- (void)setPrimitiveLastUpdateDate:(NSDate*)value;




- (NSString*)primitiveRequestId;
- (void)setPrimitiveRequestId:(NSString*)value;




- (NSString*)primitiveResponseFingerprint;
- (void)setPrimitiveResponseFingerprint:(NSString*)value;




@end

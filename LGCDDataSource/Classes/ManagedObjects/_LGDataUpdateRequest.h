// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LGDataUpdateRequest.h instead.

#import <CoreData/CoreData.h>


extern const struct LGDataUpdateRequestAttributes {
	__unsafe_unretained NSString *requestId;
	__unsafe_unretained NSString *responseFingerprint;
	__unsafe_unretained NSString *updateDate;
} LGDataUpdateRequestAttributes;

extern const struct LGDataUpdateRequestRelationships {
} LGDataUpdateRequestRelationships;

extern const struct LGDataUpdateRequestFetchedProperties {
} LGDataUpdateRequestFetchedProperties;






@interface LGDataUpdateRequestID : NSManagedObjectID {}
@end

@interface _LGDataUpdateRequest : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LGDataUpdateRequestID*)objectID;





@property (nonatomic, strong) NSString* requestId;



//- (BOOL)validateRequestId:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* responseFingerprint;



//- (BOOL)validateResponseFingerprint:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* updateDate;



//- (BOOL)validateUpdateDate:(id*)value_ error:(NSError**)error_;






@end

@interface _LGDataUpdateRequest (CoreDataGeneratedAccessors)

@end

@interface _LGDataUpdateRequest (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRequestId;
- (void)setPrimitiveRequestId:(NSString*)value;




- (NSString*)primitiveResponseFingerprint;
- (void)setPrimitiveResponseFingerprint:(NSString*)value;




- (NSDate*)primitiveUpdateDate;
- (void)setPrimitiveUpdateDate:(NSDate*)value;




@end

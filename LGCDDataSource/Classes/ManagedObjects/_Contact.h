// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Contact.h instead.

#import <CoreData/CoreData.h>


extern const struct ContactAttributes {
	__unsafe_unretained NSString *company;
	__unsafe_unretained NSString *email;
	__unsafe_unretained NSString *firstName;
	__unsafe_unretained NSString *guid;
	__unsafe_unretained NSString *lastName;
	__unsafe_unretained NSString *lastNameInitial;
	__unsafe_unretained NSString *weight;
} ContactAttributes;

extern const struct ContactRelationships {
} ContactRelationships;

extern const struct ContactFetchedProperties {
} ContactFetchedProperties;










@interface ContactID : NSManagedObjectID {}
@end

@interface _Contact : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ContactID*)objectID;





@property (nonatomic, strong) NSString* company;



//- (BOOL)validateCompany:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* email;



//- (BOOL)validateEmail:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* firstName;



//- (BOOL)validateFirstName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* guid;



//- (BOOL)validateGuid:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastName;



//- (BOOL)validateLastName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* lastNameInitial;



//- (BOOL)validateLastNameInitial:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* weight;



@property int16_t weightValue;
- (int16_t)weightValue;
- (void)setWeightValue:(int16_t)value_;

//- (BOOL)validateWeight:(id*)value_ error:(NSError**)error_;






@end

@interface _Contact (CoreDataGeneratedAccessors)

@end

@interface _Contact (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveCompany;
- (void)setPrimitiveCompany:(NSString*)value;




- (NSString*)primitiveEmail;
- (void)setPrimitiveEmail:(NSString*)value;




- (NSString*)primitiveFirstName;
- (void)setPrimitiveFirstName:(NSString*)value;




- (NSString*)primitiveGuid;
- (void)setPrimitiveGuid:(NSString*)value;




- (NSString*)primitiveLastName;
- (void)setPrimitiveLastName:(NSString*)value;




- (NSString*)primitiveLastNameInitial;
- (void)setPrimitiveLastNameInitial:(NSString*)value;




- (NSNumber*)primitiveWeight;
- (void)setPrimitiveWeight:(NSNumber*)value;

- (int16_t)primitiveWeightValue;
- (void)setPrimitiveWeightValue:(int16_t)value_;




@end

//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGCDParserInterface.h"


#define isNull(key)                    [[_currentElement objectForKey:key] isKindOfClass:[NSNull class]]
#define bindStrJ(obj, key)             obj = isNull(key) ? nil : [_currentElement objectForKey:key]
#define bindIntJ(obj, key)             obj = isNull(key) ? 0 : [[_currentElement objectForKey:key] intValue]
#define bindFloatJ(obj, key)           obj = isNull(key) ? 0 : [[_currentElement objectForKey:key] floatValue]
#define bindNumberToStringJ(obj, key)  obj = isNull(key) ? nil : [[_currentElement objectForKey:key] stringValue]
#define bindDateJ(obj, key)            obj = isNull(key) ? nil : [_dateFormatter dateFromString:[_currentElement objectForKey:key]]
#define bindDateTimeJ(obj, key)        obj = isNull(key) ? nil : [_dateTimeFormatter dateFromString:[_currentElement objectForKey:key]]
#define bindUrlFromDictJ(obj, key)	   obj = (!isNull(key) && [_currentElement objectForKey:key] != nil) ? [NSURL URLWithString:[_currentElement objectForKey:key]] : nil;
#define bindBoolFromDictJ(obj, key)    obj = isNull(key) ? NO : [[_currentElement objectForKey:key] boolValue]
#define isKeyPathNull(key)             [[_currentElement valueForKeyPath:key] isKindOfClass:[NSNull class]]
#define bindStrKeyPathJ(obj, key)      obj = isKeyPathNull(key) ? nil : [_currentElement valueForKeyPath:key]
#define bindFloatKeyPathJ(obj, key)    obj = isKeyPathNull(key) ? 0 : [[_currentElement valueForKeyPath:key] floatValue]
#define bindIntKeyPathJ(obj, key)      obj = isKeyPathNull(key) ? 0 : [[_currentElement valueForKeyPath:key] integerValue]
#define bindBoolJ(obj, key)            obj = isNull(key) ? 0 : [[_currentElement objectForKey:key] boolValue]


@interface LGAbstractCDJSONParser : NSObject <LGCDParserInterface>
{
    NSURLResponse *_response;

    NSManagedObjectContext *_context;
    NSMutableSet *_itemsSet;

    NSDateFormatter *_dateTimeFormatter;
    NSDateFormatter *_dateFormatter;
    
    id _rootJsonObject;
    NSDictionary *_currentElement;
    
    NSError *_error;
}


@end


#pragma mark - Protected


@interface LGAbstractCDJSONParser ()


- (void)initialize;
- (void)bindObject;
- (NSString *)dateTimeFormat;
- (NSString *)dateFormat;
- (NSString *)rootKeyPath;


@end
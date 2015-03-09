//
//  Created by Luka Gabrić.
//  Copyright (c) 2013 Luka Gabrić. All rights reserved.
//


#import "LGDataUpdateOperation.h"
#import <CoreData/CoreData.h>
#import "CoreData+MagicalRecord.h"
#import "LGDataUpdateRequest.h"


@implementation LGDataUpdateOperation
{
    BOOL _finished;
    BOOL _executing;
}


#pragma mark - Init


- (instancetype)initWithSession:(NSURLSession *)session
                        request:(NSURLRequest *)request
                      requestId:(NSString *)requestId
                      andParser:(id <LGCDParserInterface>)parser
{
    self = [super init];
    if (self)
    {
        NSAssert(session && request && requestId && parser, @"Dependencies are mandatory");
        
        _parser = parser;
        _requestId = [requestId copy];
        
        __weak typeof(self) weakSelf = self;
        
        _task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            LGDataUpdateOperation *strongSelf = weakSelf;
            if (!strongSelf) return;
            
            [strongSelf taskFinishedWithData:data response:response andError:error];
        }];
    }
    return self;
}


- (void)dealloc
{
#if DEBUG
    NSLog(@"%@ dealloc", [self class]);
#endif
}


#pragma mark - Task finished


- (void)taskFinishedWithData:(NSData *)data response:(NSURLResponse *)response andError:(NSError *)error
{
    if ([self isCancelled]) return;
    
    _responseData = data;
    _response = response;
    _error = error;
    
    if (_error)
    {
        [self finishOperationWithError:_error];
        return;
    }
    
    if (![self isResponseValid])
    {
        [self finishOperationWithError:[NSError errorWithDomain:@"Invalid response" code:1 userInfo:@{@"response": response}]];
        return;
    }
    
    if ([self isCancelled]) return;
    
    NSError *parsingError;
    
    if ([self isDataNew])
    {
        parsingError = [self parseData];
        [self saveRequestInfo];
    }
    
    if ([self isCancelled]) return;
    
    [self finishOperationWithError:parsingError];
}


#pragma mark - Parse data


- (NSError *)parseData
{
    __block NSError *error;
    
    [_workerContext performBlockAndWait:^{
        [_parser setContext:_workerContext];
        [_parser parseData:_responseData];
        
        error = [_parser error];
        
        if (error)
            [_workerContext reset];
        else
            [self deleteOrphanedObjectsWithParser:_parser];
    }];
    
    return error;
}


#pragma mark - Delete orphaned objects


- (void)deleteOrphanedObjectsWithParser:(id <LGCDParserInterface>)parser
{
    NSSet *items = [parser itemsSet];
    
    NSString *entityName = [parser entityName];
    
    if (!entityName || [entityName length] == 0) return;
    
    NSFetchRequest *centerRequest = [NSFetchRequest new];
    
    centerRequest.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:_workerContext];
    centerRequest.includesPropertyValues = NO;
    
    NSError *error = nil;
    
    NSArray *allObjects = [_workerContext executeFetchRequest:centerRequest error:&error];
    
    if (error)
        return;
    
    if ([allObjects count] > 0)
    {
        NSMutableSet *setToDelete = [NSMutableSet setWithArray:allObjects];
        
        [setToDelete minusSet:items];
        
        for (NSManagedObject *managedObjectToDelete in setToDelete)
        {
            [_workerContext deleteObject:managedObjectToDelete];
            
#if DEBUG
            NSLog(@"deleted object - %@", managedObjectToDelete);
#endif
        }
    }
}


#pragma mark - Get response fingerprint


- (NSString *)responseFingerprint
{
    NSDictionary *headers = [(NSHTTPURLResponse *)_response allHeaderFields];
    
    NSString *etagOrLastModified = [headers objectForKey:@"Etag"];
    
    if (!etagOrLastModified)
        etagOrLastModified = [headers objectForKey:@"Last-Modified"];
    
#if DEBUG
    if (!etagOrLastModified)
    {
        NSLog(@"No response fingerprint for request with url: '%@' and identifier: '%@'. Request needs to have a fingerprint (e.g. ETag or Last-Modified) for caching.", [self.response.URL absoluteString], _requestId);
    }
#endif
    
    return etagOrLastModified;
}


#pragma mark - Check if response is valid


- (BOOL)isResponseValid
{
    return YES;
}


#pragma mark - Finish operation


- (void)finishOperationWithError:(NSError *)error
{
    _error = error;
    
    [_dataUpdateDelegate operation:self didFinishWithError:error];
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    _executing = NO;
    _finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}


#pragma mark - Request info


- (BOOL)isDataNew
{
    __block NSString *previousFingerprint;
    
    [_workerContext performBlockAndWait:^{
        LGDataUpdateRequest *request = [LGDataUpdateRequest MR_findFirstByAttribute:@"requestId"
                                                                          withValue:_requestId
                                                                          inContext:_workerContext];
        
        previousFingerprint = request.responseFingerprint;
    }];
    
    NSString *currentFingerprint = self.responseFingerprint;
    
    BOOL isDataNew = !previousFingerprint || !currentFingerprint || ![previousFingerprint isEqualToString:currentFingerprint];
    
#if DEBUG
    NSLog(@"Data is %@new for this request.", isDataNew ? @"" : @"NOT ");
#endif
    
    return isDataNew;
}


- (void)saveRequestInfo
{
    if (_error) return;
    
    [_workerContext performBlockAndWait:^{
        LGDataUpdateRequest *request = [LGDataUpdateRequest MR_findFirstByAttribute:@"requestId"
                                                                          withValue:_requestId
                                                                          inContext:_workerContext];
        
        if (!request)
        {
            request = [LGDataUpdateRequest MR_createInContext:_workerContext];
            request.requestId = _requestId;
        }
        
        request.responseFingerprint = self.responseFingerprint;
        request.updateDate = [NSDate date];
    }];
}


#pragma mark - NSOperation


- (void)start
{
    if (self.isCancelled)
    {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [_task resume];
}


- (BOOL)isExecuting
{
    return _executing;
}


- (BOOL)isFinished
{
    return _finished;
}


- (BOOL)isConcurrent
{
    return YES;
}


- (void)cancel
{
    [super cancel];
    [_task cancel];
    [_parser abortParsing];
}


#pragma mark -


@end

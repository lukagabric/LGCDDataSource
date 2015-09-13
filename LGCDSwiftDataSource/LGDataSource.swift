//
//  LGDataSource.swift
//  LGCDDataSource
//
//  Created by Luka Gabric on 01/05/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

import UIKit
import CoreData

typealias LGDataUpdate = (data: AnyObject, response: NSURLResponse, context: NSManagedObjectContext) -> Void

class LGDataSource: NSObject {
/*
    - (PMKPromise *)updateDataPromiseWithRequest:(NSURLRequest *)request
    requestId:(NSString *)requestId
    staleInterval:(NSTimeInterval)staleInterval
    dataUpdate:(LGDataUpdate)dataUpdate;
*/
    let session: NSURLSession
    let mainContext: NSManagedObjectContext
    let bgContext: NSManagedObjectContext
    let dataUpdateQueue: NSOperationQueue
    
    init(session: NSURLSession, request: NSURLRequest, requestId: String, mainContext: NSManagedObjectContext, bgContext: NSManagedObjectContext, dataUpdate: LGDataUpdate) {
        self.session = session
        self.mainContext = mainContext
    
        self.bgContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.bgContext.parentContext = self.mainContext
        
        self.dataUpdateQueue = NSOperationQueue()
        self.dataUpdateQueue.maxConcurrentOperationCount = 1
        self.dataUpdateQueue.suspended = false
        
        super.init()
        
        self.configureBgContextNotifications()
    }
    
    func configureBgContextNotifications() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bgContextWillSave", name: NSManagedObjectContextWillSaveNotification, object: self.bgContext)
    }
    
    func bgContextWillSave() -> Void {
        let insertedObjects = self.bgContext.insertedObjects
        if insertedObjects.count == 0 { return }
        
        #if DEBUG
            NSLog("Obtaining permanent object IDs");
        #endif
        
        self.bgContext.obtainPermanentIDsForObjects(Array(insertedObjects), error: nil)
    }
}

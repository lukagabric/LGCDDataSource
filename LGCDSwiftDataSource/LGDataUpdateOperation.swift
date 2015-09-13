//
//  LGDataUpdateOperation.swift
//  LGCDDataSource
//
//  Created by Luka Gabric on 02/05/15.
//  Copyright (c) 2015 Luka Gabric. All rights reserved.
//

import UIKit
import CoreData

class LGDataUpdateOperation: NSObject {

    /*
    - (instancetype)initWithSession:(NSURLSession *)session
    request:(NSURLRequest *)request
    requestId:(NSString *)requestId
    mainContext:(NSManagedObjectContext *)mainContext
    bgContext:(NSManagedObjectContext *)bgContext
    dataUpdate:(LGDataUpdate)dataUpdate NS_DESIGNATED_INITIALIZER;
    
    @property (readonly, nonatomic) NSString *requestId;
    @property (readonly, nonatomic) PMKPromise *promise;
    */
    
    let session: NSURLSession
    let request: NSURLRequest
    let requestId: String
    let mainContext: NSManagedObjectContext
    let bgContext: NSManagedObjectContext
    let dataUpdate: LGDataUpdate
    
    init(session: NSURLSession, request: NSURLRequest, requestId: String, mainContext: NSManagedObjectContext, bgContext: NSManagedObjectContext, dataUpdate: LGDataUpdate) {
        self.session = session
        self.request = request
        self.requestId = requestId
        self.mainContext = mainContext
        self.bgContext = bgContext
        self.dataUpdate = dataUpdate
        super.init()
    }

}

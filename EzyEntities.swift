//
//  EzyEntities.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyZone {
    public let id : Int
    public let name : String
    public let client : EzyClient
    public let appManager: EzyAppManager
    
    public init(client : EzyClient, id: Int, name: String) {
        self.id = id;
        self.name = name;
        self.client = client;
        self.appManager = EzyAppManager(zoneName: name);
    }
    
    public func getApp() -> EzyApp {
        let app = appManager.getApp()
        return app
    }
}

public class EzyApp {
    public let id : Int
    public let name : String
    public let zone : EzyZone
    private let client : EzyClient
    private let dataHandlers : EzyAppDataHandlers
    
    public init(client: EzyClient, zone: EzyZone, id: Int, name: String) {
        self.id = id
        self.name = name
        self.client = client
        self.zone = zone
        self.dataHandlers = client.handlerManager!.getAppDataHandlers(appName: name)
    }
    
    public func sendRequest(cmd: Any, data: NSObject) -> Void {
        let requestData = NSMutableArray()
        requestData.add(self.id);
        let requestParams = NSMutableArray()
        requestParams.add(cmd)
        requestParams.add(data)
        requestData.add(requestParams)
        self.client.sendRequest(cmd: EzyCommand.APP_REQUEST, data: requestData)
    }
    
    public func getDataHandler(cmd: Any) -> EzyAppDataHandler? {
        let handler = self.dataHandlers.getHandler(cmd: cmd)
        return handler
    }
}

public class EzyUser {
    public let id : Int64
    public let name : String
    
    public init(id: Int64, name: String) {
        self.id = id 
        self.name = name
    }
}

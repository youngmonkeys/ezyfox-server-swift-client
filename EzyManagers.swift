//
//  EzyManagers.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyAppManager {
    
    public let zoneName : String
    private let appList : NSMutableArray
    private let appsById : NSMutableDictionary
    private let appsByName : NSMutableDictionary
    
    public init(zoneName: String) {
        self.zoneName = zoneName
        self.appList = NSMutableArray()
        self.appsById = NSMutableDictionary()
        self.appsByName = NSMutableDictionary()
    }
    
    public func getApp() -> EzyApp {
        var app : Any? = nil
        if(self.appList.count > 0) {
            app = self.appList[0]
        }
        else {
            EzyLogger.warn(msg: "has no app in zone: \(self.zoneName)");
        }
        return app as! EzyApp
    }
    
    public func addApp(app: EzyApp) -> Void {
        self.appList.add(app)
        self.appsById[app.id] = app
        self.appsByName[app.name] = app
    }
    
    public func removeApp(appId: Int) -> EzyApp? {
        let app = self.appsById[appId] as? EzyApp;
        if(app != nil) {
            self.appList.remove(app!);
            self.appsById.removeObject(forKey: appId);
            self.appsByName.removeObject(forKey: app!.name)
        }
        return app;
    }
    
    public func getAppById(id: Int) -> EzyApp {
        let app = self.appsById[id]
        return app as! EzyApp
    }
    
    public func getAppByName(name: String) -> EzyApp {
        let app = self.appsByName[name]
        return app as! EzyApp
    }
}

//===================================================

public class EzyHandlerManager {
    
    private let client : EzyClient
    public var dataHandlers : EzyDataHandlers?
    public var eventHandlers : EzyEventHandlers?
    private let appDataHandlerss : NSMutableDictionary
    
    public static func create(client: EzyClient) -> EzyHandlerManager {
        let pRet = EzyHandlerManager(client: client)
        pRet.postInit()
        return pRet
    }
    
    public init(client: EzyClient) {
        self.client = client;
        self.appDataHandlerss = NSMutableDictionary()
        self.dataHandlers = nil
        self.eventHandlers = nil
    }
    
    private func postInit() -> Void {
        self.dataHandlers = self.newDataHandlers()
        self.eventHandlers = self.newEventHandlers()
    }
    
    private func newEventHandlers() -> EzyEventHandlers {
        let handlers = EzyEventHandlers(client: self.client)
        handlers.addHandler(eventType: EzyEventType.CONNECTION_SUCCESS, handler: EzyConnectionSuccessHandler())
        handlers.addHandler(eventType: EzyEventType.CONNECTION_FAILURE, handler: EzyConnectionFailureHandler())
        handlers.addHandler(eventType: EzyEventType.DISCONNECTION, handler: EzyDisconnectionHandler())
        return handlers
    }
    
    private func newDataHandlers() -> EzyDataHandlers {
        let handlers = EzyDataHandlers(client: self.client);
        handlers.addHandler(cmd: EzyCommand.PONG, handler: EzyPongHandler())
        handlers.addHandler(cmd: EzyCommand.HANDSHAKE, handler: EzyHandshakeHandler())
        handlers.addHandler(cmd: EzyCommand.LOGIN, handler: EzyLoginSuccessHandler())
        handlers.addHandler(cmd: EzyCommand.LOGIN_ERROR, handler: EzyLoginErrorHandler())
        handlers.addHandler(cmd: EzyCommand.APP_ACCESS, handler: EzyAppAccessHandler())
        handlers.addHandler(cmd: EzyCommand.APP_EXIT, handler: EzyAppExitHandler())
        handlers.addHandler(cmd: EzyCommand.APP_REQUEST, handler: EzyAppResponseHandler())
        return handlers;
    }
    
    public func getDataHandler(cmd: String) -> EzyDataHandler? {
        let handler = self.dataHandlers!.getHandler(cmd: cmd)
        return handler
    }
    
    public func getEventHandler(eventType: String) -> EzyEventHandler? {
        let handler = self.eventHandlers!.getHandler(eventType: eventType)
        return handler
    }
    
    public func getAppDataHandlers(appName: String) -> EzyAppDataHandlers {
        var answer = self.appDataHandlerss[appName]
        if(answer == nil) {
            answer = EzyAppDataHandlers()
            self.appDataHandlerss[appName] = answer
        }
        return answer as! EzyAppDataHandlers
    }
    
    public func addDataHandler(cmd: String, handler: EzyDataHandler) -> Void {
        self.dataHandlers!.addHandler(cmd: cmd, handler: handler)
    }
    
    public func addEventHandler(eventType: String, handler: EzyEventHandler) -> Void {
        self.eventHandlers!.addHandler(eventType: eventType, handler: handler)
    }
}

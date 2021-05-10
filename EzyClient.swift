//
//  EzyClientProxy.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyClient {
    
    public let config       : NSDictionary
    public let name         : String
    public var zone         : EzyZone?
    public var me           : EzyUser?
    public var setup        : EzySetup?
    public var handlerManager : EzyHandlerManager?
    private let proxy = EzyClientProxy.getInstance()
    
    public init(config: NSDictionary) {
        let result = proxy.run("init", params: config as! [AnyHashable : Any])
        self.config = result as! NSDictionary;
        self.name = self.config["clientName"] as! String
        self.zone = nil
        self.me = nil
        self.setup = nil
        self.handlerManager = nil
    }
    
    public func postInit() {
        self.handlerManager = EzyHandlerManager.create(client: self)
        self.setup = EzySetup(handlerManager: handlerManager!)
    }
    
    public func connect(host:String, port:Int) -> Void {
        let params = NSMutableDictionary()
        params["clientName"] = name
        params["host"] = host
        params["port"] = port
        proxy.run("connect", params: params as! [AnyHashable : Any])
    }
    
    public func reconnect() -> Bool {
        let params = NSMutableDictionary()
        params["clientName"] = name
        let result = proxy.run("reconnect", params: params as! [AnyHashable : Any])
        return result as! Bool
    }
    
    public func disconnect(reason:Int = EzyDisconnectReason.CLOSE) -> Void {
        let params = NSMutableDictionary()
        params["reason"] = reason;
        proxy.run("disconnect", params: params as! [AnyHashable : Any])
    }
    
    public func sendRequest(cmd: String, data: NSArray) -> Void {
        let params = NSMutableDictionary()
        params["clientName"] = name
        let requestParams = NSMutableDictionary()
        requestParams["command"] = cmd
        requestParams["data"] = data
        params["request"] = requestParams
        proxy.run("send", params: params as! [AnyHashable : Any])
    }
    
    public func startPingSchedule() -> Void {
        let params = NSMutableDictionary()
        params["clientName"] = name
        proxy.run("startPingSchedule", params: params as! [AnyHashable : Any])
    }
    
    public func setStatus(status: String) -> Void {
        let params = NSMutableDictionary()
        params["clientName"] = name
        params["status"] = status
        proxy.run("setStatus", params: params as! [AnyHashable : Any])
    }
    
    public func getApp() -> EzyApp? {
        if(zone != nil) {
            let appManager = zone!.appManager;
            let app = appManager.getApp()
            return app;
        }
        return nil;
    }
    
    public func getAppById(appId: Int) -> EzyApp? {
        if(zone != nil) {
            let appManager = zone!.appManager;
            let app = appManager.getAppById(id: appId);
            return app;
        }
        return nil;
    }
    
    public func handleEvent(eventType: String, data: NSDictionary) -> Void {
        let eventHandlers = self.handlerManager!.eventHandlers
        eventHandlers!.handle(eventType: eventType, data: data)
    }
    
    public func handleData(command: String, data: NSArray) -> Void {
        let dataHandlers = self.handlerManager!.dataHandlers
        dataHandlers!.handle(cmd: command, data: data)
    }
}

//
//  EzyClientProxy.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyClient {
    
    public let enableSSL    : Bool
    public let sslType      : Int
    public let enableDebug  : Bool
    public let config       : NSDictionary
    public let name         : String
    public var zone         : EzyZone?
    public var me           : EzyUser?
    public var setup        : EzySetup?
    public var handlerManager : EzyHandlerManager?
    public var privateKey   : String?
    public var sessionId    : Int64?
    public var sessionToken : String?
    public var sessionKey   : Data?
    private let proxy = EzyClientProxy.getInstance()
    
    public convenience init(config: EzyClientConfig) {
        self.init(config: config.toDictionary())
    }
    
    public init(config: NSDictionary) {
        let result = proxy.run("init", params: config as! [AnyHashable : Any])
        self.config = result as! NSDictionary;
        self.name = self.config["clientName"] as! String
        self.enableSSL = config["enableSSL"] != nil ? config["enableSSL"] as! Bool : false
        self.sslType = config["sslType"] != nil ? config["sslType"] as! Int : EzySslType.L7;
        self.enableDebug = config["enableDebug"] != nil ? config["enableDebug"] as! Bool : false
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
        self.privateKey = nil;
        self.sessionKey = nil;
        let params = NSMutableDictionary()
        params["clientName"] = name
        params["host"] = host
        params["port"] = port
        proxy.run("connect", params: params as! [AnyHashable : Any])
    }
    
    public func reconnect() -> Bool {
        self.privateKey = nil;
        self.sessionKey = nil;
        let params = NSMutableDictionary()
        params["clientName"] = name
        let result = proxy.run("reconnect", params: params as! [AnyHashable : Any])
        return result as! Bool
    }
    
    public func disconnect(reason:Int = EzyDisconnectReason.CLOSE) -> Void {
        let params = NSMutableDictionary()
        params["clientName"] = name
        params["reason"] = reason
        proxy.run("disconnect", params: params as! [AnyHashable : Any])
    }
    
    public func close() -> Void {
        disconnect();
    }
    
    public func send(cmd: String, data: NSArray, encrypted: Bool = false) -> Void {
        var shouldEncrypted = encrypted;
        if(isEnableL7SSL() && sessionKey == nil) {
            if(enableDebug) {
                shouldEncrypted = false;
            }
            else {
                EzyLogger.error(msg: "can not send command: " + cmd + " you must enable SSL " +
                                     "or enable debug mode by configuration when you create the client")
                return;
            }
            
        }
        let params = NSMutableDictionary()
        params["clientName"] = name
        let requestParams = NSMutableDictionary()
        requestParams["command"] = cmd
        requestParams["data"] = data
        requestParams["encrypted"] = shouldEncrypted
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
    
    public func setSessionKey(sessionKey: Data) -> Void {
        self.sessionKey = sessionKey;
        let params = NSMutableDictionary()
        params["clientName"] = name
        params["sessionKey"] = sessionKey
        proxy.run("setSessionKey", params: params as! [AnyHashable : Any])
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

    public func isEnableL7SSL() -> Bool {
        return enableSSL && sslType == EzySslType.L7;
    }
}

//
//  EzyHandlers.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyEventHandler {
    public func handle(event: NSDictionary) -> Void {}
}

public class EzyDataHandler {
    public func handle(data: NSArray) -> Void {}
}

public class EzyAbstractEventHandler : EzyEventHandler{
    public var client : EzyClient?
    
    public override init() {
        self.client = nil
    }
}

public class EzyAbstractDataHandler : EzyDataHandler {
    public var client : EzyClient?
    
    public override init() {
        self.client = nil
    }
}

public class EzyAppDataHandler {
    public func handle(app: EzyApp, data: NSObject) -> Void {}
}

public class EzyAbstractAppDataHandler<D> : EzyAppDataHandler {
    
    public override func handle(app: EzyApp, data: NSObject) -> Void {
        process(app: app, data: data as! D)
    }
    
    public func process(app: EzyApp, data: D) {}
}

public class EzyConnectionSuccessHandler : EzyAbstractEventHandler {
    public let clientType = "SWIFT"
    public let clientVersion = "1.0.0"
    
    public override init() {}
    
    public override func handle(event: NSDictionary) {
        self.sendHandshakeRequest()
        self.postHandle()
    }
    
    public func postHandle() -> Void {
    }
    
    public func sendHandshakeRequest() -> Void {
        let request = newHandshakeRequest()
        self.client!.send(cmd: EzyCommand.HANDSHAKE, data: request)
    }
    
    public func newHandshakeRequest() -> NSMutableArray {
        let clientId = self.getClientId()
        let clientKey = self.generateClientKey()
        let enableEncryption = self.client!.enableSSL
        let token = self.getStoredToken()
        let request = NSMutableArray()
        request.add(clientId)
        request.add(clientKey as Any)
        request.add(clientType)
        request.add(clientVersion)
        request.add(EzyNSNumber(bool: enableEncryption))
        request.add(token)
        return request
    }
    
    public func generateClientKey() -> String? {
        if(client!.enableSSL) {
            let keyPair = EzyRSAProxy.getInstance().generateKeyPair()
            client?.privateKey = keyPair.privateKey
            return keyPair.publicKey
        }
        return nil
    }
    
    public func getClientId() -> String {
        let uuid = UUID().uuidString
        return uuid
    }
    
    public func getStoredToken() -> String {
        return ""
    }
    
}

//=======================================================
public class EzyConnectionFailureHandler : EzyAbstractEventHandler {
    public override func handle(event: NSDictionary) {
        let reason = event["reason"] as! Int
        let reasonName = EzyConnectionFailedReasons.getConnectionFailedReasonName(reasonId: reason)
        EzyLogger.warn(msg: "connection failure, reason = \(reasonName)")
        let config = self.client!.config
        let reconnectConfig = config["reconnect"] as! NSDictionary
        let should = self.shouldReconnect(event: event)
        let reconnectEnable = reconnectConfig["enable"] as! Bool
        let mustReconnect = reconnectEnable && should
        var reconnecting = false
        self.client!.setStatus(status: EzyConnectionStatus.FAILURE)
        if(mustReconnect) {
            reconnecting = client!.reconnect()
        }
        if(reconnecting) {
            self.onReconnecting(event: event)
        }
        else {
            self.onConnectionFailed(event: event)
        }
        postHandle(event: event)
    }
    
    public func shouldReconnect(event: NSDictionary) -> Bool {
        return true
    }
    
    public func onReconnecting(event: NSDictionary) -> Void {
    }
    
    public func onConnectionFailed(event: NSDictionary) -> Void {
    }
    
    public func postHandle(event: NSDictionary) -> Void {
    }
    
}

//=======================================================
public class EzyDisconnectionHandler : EzyAbstractEventHandler {
    public override func handle(event: NSDictionary) -> Void {
        let reason = event["reason"] as! Int
        let reasonName = EzyDisconnectReasons.getDisconnectReasonName(reasonId: reason)
        EzyLogger.info(msg: "handle disconnection, reason = \(reasonName)")
        preHandle(event: event)
        let config = self.client!.config
        let reconnectConfig = config["reconnect"] as! NSDictionary
        let should = self.shouldReconnect(event: event)
        let reconnectEnable = reconnectConfig["enable"] as! Bool
        let mustReconnect = reconnectEnable &&
            reason != EzyDisconnectReason.UNAUTHORIZED &&
            reason != EzyDisconnectReason.CLOSE &&
            should
        var reconnecting = false
        self.client!.setStatus(status: EzyConnectionStatus.DISCONNECTED)
        if(mustReconnect) {
            reconnecting = client!.reconnect()
        }
        if(reconnecting) {
            self.onReconnecting(event: event)
        }
        else {
            self.onDisconnected(event: event)
        }
        postHandle(event: event)
    }
    
    public func preHandle(event: NSDictionary) -> Void {
    }
    
    public func shouldReconnect(event: NSDictionary) -> Bool {
        let reason = event["reason"] as! Int
        if(reason == EzyDisconnectReason.ANOTHER_SESSION_LOGIN) {
            return false
        }
        return true
    }
    
    public func onReconnecting(event : NSDictionary) -> Void {
    }
    
    public func onDisconnected(event : NSDictionary) -> Void {
    }
    
    public func postHandle(event: NSDictionary) -> Void {
    }
}

//=======================================================
public class EzyPongHandler : EzyAbstractDataHandler {
}

//=======================================================

public class EzyHandshakeHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        self.startPing()
        if(self.doHandle(data: data)) {
            self.handleLogin()
        }
        self.postHandle(data: data)
    }
    
    public func doHandle(data: NSArray) -> Bool {
        client?.sessionToken = data[1] as? String
        client?.sessionId = data[2] as? Int64
        if(client!.enableSSL) {
            let sessionKey = decrypteSessionKey(encyptedSessionKey: data[3])
            if(sessionKey == nil) {
                return false
            }
            client!.setSessionKey(sessionKey: sessionKey!)
        }
        return true
    }
    
    public func decrypteSessionKey(encyptedSessionKey: Any) -> Data? {
        if(encyptedSessionKey is NSNull) {
            if(client!.enableDebug) {
                return Data()
            }
            EzyLogger.error(msg: "maybe server was not enable SSL, you must enable SSL on server or disable SSL on your client or enable debug mode")
            client?.close()
            return nil
        }
        let privateKey = client?.privateKey
        return EzyRSAProxy.getInstance().decrypt(encyptedSessionKey as! NSByteArray, privateKey: privateKey!)
    }
    
    public func postHandle(data: NSArray) -> Void {
    }
    
    public func handleLogin() -> Void {
        let loginRequest = self.getLoginRequest()
        self.client!.send(cmd: EzyCommand.LOGIN, data: loginRequest, encrypted: encryptedLoginRequest())
    }
    
    public func encryptedLoginRequest() -> Bool {
        return false
    }
    
    public func getLoginRequest() -> NSArray {
        let array = NSMutableArray()
        array.add("test")
        array.add("test")
        array.add("test")
        array.add(NSMutableArray())
        return array
    }
    
    public func startPing() -> Void {
        self.client!.startPingSchedule()
    }
}

//=======================================================
public class EzyLoginSuccessHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        let responseData = data[4] as! NSObject
        let user = newUser(data: data)
        let zone = newZone(data: data)
        self.client!.me = user
        self.client!.zone = zone
        self.handleLoginSuccess(responseData: responseData)
        EzyLogger.info(msg: "user: \(user.name) logged in successfully")
    }
    
    public func newUser(data: NSArray) -> EzyUser {
        let userId = data[2] as! Int64
        let username = data[3] as! String
        let user = EzyUser(id: userId, name: username)
        return user
    }
    
    public func newZone(data: NSArray) -> EzyZone {
        let zoneId = data[0] as! Int
        let zoneName = data[1] as! String
        let zone = EzyZone(client: self.client!, id: zoneId, name: zoneName)
        return zone
    }
    
    public func handleLoginSuccess(responseData: NSObject) -> Void {
    }
    
}

//=======================================================
public class EzyLoginErrorHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        self.client!.disconnect(reason: EzyDisconnectReason.UNAUTHORIZED)
        self.handleLoginError(data: data)
    }
    
    public func handleLoginError(data: NSArray) -> Void {
    }
    
}

//=======================================================
public class EzyAppAccessHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        let zone = self.client!.zone
        let appManager = zone!.appManager
        let app = self.newApp(zone: zone!, data: data)
        appManager.addApp(app: app)
        self.postHandle(app: app, data: data)
        EzyLogger.info(msg: "access app: \(app.name) successfully")
    }
    
    public func newApp(zone: EzyZone, data: NSArray) -> EzyApp {
        let appId = data[0] as! Int
        let appName = data[1] as! String
        let app = EzyApp(client: client!, zone: zone, id: appId, name: appName)
        return app
    }
    
    public func postHandle(app: EzyApp, data: NSObject) -> Void {
    }
}

//=======================================================
public class EzyAppExitHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        let zone = self.client!.zone
        let appManager = zone!.appManager
        let appId = data[0] as! Int
        let reasonId = data[1] as! Int
        let app = appManager.removeApp(appId: appId)
        if(app != nil) {
            self.postHandle(app: app!, data: data)
            EzyLogger.info(msg: "user exit app: \(app!.name), reason: \(reasonId)")
        }
    }
    
    public func postHandle(app: EzyApp, data: NSObject) -> Void {
    }
}

//=======================================================
public class EzyAppResponseHandler : EzyAbstractDataHandler {
    public override func handle(data: NSArray) -> Void {
        let appId = data[0] as! Int
        let responseData = data[1] as! NSArray
        let cmd = responseData[0]
        let commandData = responseData[1] as! NSObject
        
        let app = self.client?.getAppById(appId: appId)!
        if(app == nil) {
            EzyLogger.info(msg: "receive message when has not joined app yet")
            return
        }
        let handler = app!.getDataHandler(cmd: cmd)
        if(handler != nil) {
            handler!.handle(app: app!, data: commandData)
        }
        else {
            EzyLogger.warn(msg: "app: \(app!.name) has no handler for command: \(cmd)")
        }
    }
}

//=======================================================
public class EzyEventHandlers {
    private let client : EzyClient
    private let handlers : NSMutableDictionary
    
    public init(client: EzyClient) {
        self.client = client
        self.handlers = NSMutableDictionary()
    }
    
    public func addHandler(eventType: String, handler: EzyEventHandler) {
        let abs = handler as! EzyAbstractEventHandler
        abs.client = self.client
        self.handlers[eventType] = handler
    }
    
    public func getHandler(eventType: String) -> EzyEventHandler? {
        let handler = self.handlers[eventType]
        if(handler != nil) {
            return (handler as? EzyEventHandler)
        }
        return nil
    }
    
    public func handle(eventType: String, data: NSDictionary) -> Void {
        let handler = self.getHandler(eventType: eventType)
        if(handler != nil) {
            handler!.handle(event: data)
        }
        else {
            EzyLogger.warn(msg: "has no handler with event: \(eventType)")
        }
    }
}

//=======================================================

public class EzyDataHandlers {
    private let client : EzyClient
    private let handlers : NSMutableDictionary
    
    public init(client: EzyClient) {
        self.client = client
        self.handlers = NSMutableDictionary()
    }
    
    public func addHandler(cmd: String, handler: EzyDataHandler) -> Void {
        let abs = handler as! EzyAbstractDataHandler
        abs.client = self.client
        self.handlers[cmd] = handler
    }
    
    public func getHandler(cmd: String) -> EzyDataHandler? {
        let handler = self.handlers[cmd]
        if(handler != nil) {
            return (handler as? EzyDataHandler)
        }
        return nil
    }
    
    public func handle(cmd: String, data: NSArray) -> Void {
        let handler = self.getHandler(cmd: cmd)
        if(handler != nil) {
            handler!.handle(data: data)
        }
        else {
            EzyLogger.warn(msg: "has no handler with command: \(cmd)")
        }
    }
}

//=======================================================

public class EzyAppDataHandlers {
    private let handlers :  NSMutableDictionary
    
    public init() {
        self.handlers = NSMutableDictionary()
    }
    
    public func addHandler(cmd: Any, handler: EzyAppDataHandler) -> Void {
        self.handlers[cmd] = handler
    }
    
    public func getHandler(cmd: Any) -> EzyAppDataHandler? {
        let handler = self.handlers[cmd]
        return (handler as? EzyAppDataHandler)
    }
    
}

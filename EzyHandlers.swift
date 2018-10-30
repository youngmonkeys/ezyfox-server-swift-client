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
        self.sendHandshakeRequest();
        self.postHandle();
    }
    
    public func postHandle() -> Void {
    }
    
    public func sendHandshakeRequest() -> Void {
        let request = newHandshakeRequest();
        self.client!.sendRequest(cmd: EzyCommand.HANDSHAKE, data: request);
    }
    
    public func newHandshakeRequest() -> NSMutableArray {
        let clientId = self.getClientId()
        let clientKey = self.getClientKey()
        let enableEncryption = self.isEnableEncryption()
        let token = self.getStoredToken()
        let request = NSMutableArray()
        request.add(clientId)
        request.add(clientKey)
        request.add(clientType)
        request.add(clientVersion)
        request.add(enableEncryption)
        request.add(token)
        return request
    }
    
    public func getClientKey() -> String {
        return "";
    }
    
    public func getClientId() -> String {
        let uuid = UUID().uuidString
        return uuid;
    }
    
    public func isEnableEncryption() -> Bool {
        return false;
    }
    
    public func getStoredToken() -> String {
        return "";
    }
    
}
//=======================================================

public class EzyConnectionFailureHandler : EzyAbstractEventHandler {
    public override func handle(event: NSDictionary) {
        let reason = event["reason"] as! String
        print("connection failure, reason = \(reason)")
        let config = self.client!.config
        let reconnectConfig = config["reconnect"] as! NSDictionary
        let should = self.shouldReconnect(event: event)
        let reconnectEnable = reconnectConfig["enable"] as! Bool
        let must = reconnectEnable && should;
        var reconnecting = false;
        if(must) {
            reconnecting = client!.reconnect();
        }
        if(!reconnecting) {
            self.processWhenNoReconnect(event: event);
        }
    }
    
    public func processWhenNoReconnect(event: NSDictionary) {
        self.client!.setStatus(status: EzyConnectionStatus.FAILURE);
        self.control(event: event);
    }
    
    public func shouldReconnect(event: NSDictionary) -> Bool {
        return true;
    }
    
    public func control(event: NSDictionary) -> Void {
    }
    
}

//=======================================================
class EzyDisconnectionHandler : EzyAbstractEventHandler {
    public override func handle(event: NSDictionary) -> Void {
        let reason = event["reason"] as! String
        print("handle disconnection, reason = \(reason)")
        let config = self.client!.config
        let reconnectConfig = config["reconnect"] as! NSDictionary
        let should = self.shouldReconnect(event: event)
        let reconnectEnable = reconnectConfig["enable"] as! Bool
        let must = reconnectEnable && should;
        var reconnecting = false;
        if(must) {
            reconnecting = client!.reconnect();
        }
        if(!reconnecting) {
            self.processWhenNoReconnect(event: event);
        }
    }
    
    public func processWhenNoReconnect(event: NSDictionary) -> Void {
        self.client!.setStatus(status: EzyConnectionStatus.DISCONNECTED);
        self.control(event: event);
    }
    
    public func preHandle(event: NSDictionary) -> Void {
    }
    
    public func shouldReconnect(event: NSDictionary) -> Bool {
        return true;
    }
    
    public func control(event : NSDictionary) -> Void {
    }
}

//=======================================================
public class EzyPongHandler : EzyAbstractDataHandler {
}

//=======================================================

public class EzyHandshakeHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        self.startPing();
        self.handleLogin();
        self.postHandle(data: data);
    }
    
    public func postHandle(data: NSArray) -> Void {
    }
    
    public func handleLogin() -> Void {
        let loginRequest = self.getLoginRequest();
        self.client!.sendRequest(cmd: EzyCommand.LOGIN, data: loginRequest);
    }
    
    public func getLoginRequest() -> NSArray {
        let array = NSMutableArray();
        array.add("test")
        array.add("test")
        array.add("test")
        array.add(NSMutableArray())
        return array
    }
    
    public func startPing() -> Void {
        self.client!.startPingSchedule();
    }
}

//=======================================================
public class EzyLoginSuccessHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        let zoneId = data[0] as! Int;
        let zoneName = data[1] as! String;
        let userId = data[2] as! Int64;
        let username = data[3] as! String;
        let joinedAppArray = data[4] as! NSArray;
        let responseData = data[5] as! NSObject;
        
        let zone = EzyZone(client: self.client!, id: zoneId, name: zoneName);
        let user = EzyUser(id: userId, name: username);
        self.client!.me = user;
        self.client!.zone = zone;
        let allowReconnect = self.allowReconnection();
        let appCount = joinedAppArray.count;
        let shouldReconnect = allowReconnect && appCount > 0;
        self.handleResponseData(data: responseData);
        if(shouldReconnect) {
            self.handleResponseAppDatas(appDatas: joinedAppArray);
            self.handleReconnectSuccess(data: responseData);
        }
        else {
            self.handleLoginSuccess(data: responseData);
        }
        print("user: \(user.name) logged in successfully");
    }
    
    public func allowReconnection() -> Bool {
        return false;
    }
    
    public func handleResponseData(data: NSObject) -> Void {
    }
    
    public func handleResponseAppDatas(appDatas: NSArray) -> Void {
        let handlerManager = self.client!.handlerManager;
        let appAccessHandler = handlerManager!.getDataHandler(cmd: EzyCommand.APP_ACCESS);
        for appData in appDatas {
            appAccessHandler!.handle(data: appData as! NSArray);
        }
    }
    
    public func handleLoginSuccess(data: NSObject) -> Void {
    }
    
    public func handleReconnectSuccess(data: NSObject) -> Void {
        self.handleLoginSuccess(data: data);
    }
}

//=======================================================

public class EzyAppAccessHandler : EzyAbstractDataHandler {
    
    public override func handle(data: NSArray) -> Void {
        let zone = self.client!.zone;
        let appManager = zone!.appManager;
        let app = self.newApp(zone: zone!, data: data);
        appManager.addApp(app: app);
        self.client!.addApp(app: app);
        self.postHandle(app: app, data: data);
        print("access app: \(app.name) successfully");
    }
    
    public func newApp(zone: EzyZone, data: NSArray) -> EzyApp {
        let appId = data[0] as! Int;
        let appName = data[1] as! String;
        let app = EzyApp(client: client!, zone: zone, id: appId, name: appName);
        return app;
    }
    
    public func postHandle(app: EzyApp, data: NSObject) -> Void {
    }
}
//=======================================================

public class EzyAppResponseHandler : EzyAbstractDataHandler {
    public override func handle(data: NSArray) -> Void {
        let appId = data[0] as! Int;
        let responseData = data[1] as! NSArray;
        let cmd = responseData[0];
        let commandData = responseData[1] as! NSObject;
        
        let app = self.client!.getAppById(appId: appId);
        let handler = app.getDataHandler(cmd: cmd);
        if(handler != nil) {
            handler!.handle(app: app, data: commandData);
        }
        else {
            print("app: \(app.name) has no handler for command: \(cmd)")
        }
    }
}

//=======================================================
public class EzyEventHandlers {
    private let client : EzyClient
    private let handlers : NSMutableDictionary
    
    public init(client: EzyClient) {
        self.client = client;
        self.handlers = NSMutableDictionary();
    }
    
    public func addHandler(eventType: String, handler: EzyEventHandler) {
        let abs = handler as! EzyAbstractEventHandler
        abs.client = self.client;
        self.handlers[eventType] = handler;
    }
    
    public func getHandler(eventType: String) -> EzyEventHandler? {
        let handler = self.handlers[eventType];
        return (handler as! EzyEventHandler);
    }
    
    public func handle(eventType: String, data: NSDictionary) -> Void {
        let handler = self.getHandler(eventType: eventType);
        if(handler != nil) {
            handler!.handle(event: data);
        }
        else {
            print("has no handler with event: \(eventType)");
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
        abs.client = self.client;
        self.handlers[cmd] = handler;
    }
    
    public func getHandler(cmd: String) -> EzyDataHandler? {
        let handler = self.handlers[cmd];
        return (handler as! EzyDataHandler);
    }
    
    public func handle(cmd: String, data: NSArray) -> Void {
        let handler = self.getHandler(cmd: cmd);
        if(handler != nil) {
            handler!.handle(data: data);
        }
        else {
            print("has no handler with command: \(cmd)");
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
        self.handlers[cmd] = handler;
    }
    
    public func getHandler(cmd: Any) -> EzyAppDataHandler? {
        let handler = self.handlers[cmd];
        return (handler as! EzyAppDataHandler);
    }
    
}

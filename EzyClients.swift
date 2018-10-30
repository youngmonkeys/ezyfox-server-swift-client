//
//  EzyClients.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

class EzyClients {
    private var defaultClientName : String
    private var clients : [String : EzyClient]
    private var proxy = EzyClientProxy.getInstance();
    private static let INSTANCE = EzyClients()
    
    public static func getInstance() -> EzyClients! {
        return INSTANCE;
    }
    
    private init() {
        defaultClientName = ""
        clients = [String : EzyClient]()
    }
    
    public func newClient(config: NSDictionary) -> EzyClient {
        let client =  EzyClient(config: config)
        self.addClient(client : client)
        if(defaultClientName == "") {
            defaultClientName = client.name
        }
        return client;
    }
    
    public func newDefaultClient(config: NSDictionary) -> EzyClient {
        let client = self.newClient(config : config)
        self.defaultClientName = client.name
        return client;
    }
    
    public func addClient(client: EzyClient) -> Void {
        client.postInit()
        self.clients[client.name] = client
    }
    
    public func getClient(clientName: String) -> EzyClient {
        let client = self.clients[clientName]!
        return client;
    }
    
    public func getDefaultClient() -> EzyClient {
        let client = self.clients[defaultClientName]!
        return client
    }
    
    public func processEvents() -> Void {
        addEventDataListers()
    }
    
    private func startEventsLoop() -> Void {
        proxy.run("processEvents", params: NSDictionary() as! [AnyHashable : Any])
    }
    
    private func addEventDataListers() {
        let eventEmitter = EzyEventEmitter.getInstance()
        eventEmitter.setEventListener(String("ezy.event"), listener: {
            params in
            let client = self.getClient(clientName: params["clientName"] as! String);
            let eventType = params["eventType"] as! String;
            let data = params["data"] as! NSDictionary;
            client.handleEvent(eventType: eventType, data: data);
        });
        eventEmitter.setEventListener(String("ezy.data"), listener: {
            params in
            let client = self.getClient(clientName: params["clientName"] as! String);
            let command = params["command"] as! String;
            let data = params["data"] as! NSArray;
            client.handleData(command: command, data: data);
        });
    }
    
}

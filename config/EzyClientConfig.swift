//
//  EzyClientConfig.swift
//  ezyfox-ssl
//
//  Created by Dzung on 01/06/2021.
//

import Foundation

public class EzyClientConfig {
    
    var enableSSL: Bool?
    var sslType: Int = EzySslType.L4;
    var clientName: String?
    var zoneName: String?
    var enableDebug: Bool?
    var ping: EzyPingConfig = EzyPingConfig()
    var reconnect: EzyReconnectConfig = EzyReconnectConfig()
    
    func setClientName(clientName: String) -> EzyClientConfig {
        self.clientName = clientName
        return self
    }
    
    func setZoneName(zoneName: String) -> EzyClientConfig {
        self.zoneName = zoneName
        return self
    }
    
    func setEnableSSL(enableSSL: Bool = true) -> EzyClientConfig {
        self.enableSSL = enableSSL
        return self
    }

    func setSslType(sslType: Int) -> EzyClientConfig {
        self.sslType = sslType;
        return self;
    }
    
    func setEnableDebug(enableDebug: Bool = true) -> EzyClientConfig {
        self.enableDebug = enableDebug;
        return self
    }
    
    func setPing(ping: EzyPingConfig) -> EzyClientConfig {
        self.ping = ping
        return self
    }
    
    func setReconnect(reconnect: EzyReconnectConfig) -> EzyClientConfig {
        self.reconnect = reconnect
        return self
    }
    
    func getClientName() -> String {
        if(clientName != nil) {
            return clientName!
        }
        if(zoneName != nil) {
            return zoneName!
        }
        return ""
    }
    
    func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["clientName"] = getClientName()
        dict["zoneName"] = zoneName
        dict["enableSSL"] = enableSSL
        dict["sslType"] = sslType;
        dict["enableDebug"] = enableDebug
        dict["ping"] = ping.toDictionary()
        dict["reconnect"] = reconnect.toDictionary()
        return dict
    }
    
}

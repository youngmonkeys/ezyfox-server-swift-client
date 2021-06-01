//
//  EzyClientConfig.swift
//  ezyfox-ssl
//
//  Created by Dzung on 01/06/2021.
//

import Foundation

public class EzyClientConfig {
    
    var enableSSL: Bool?
    var clientName: String?
    var zoneName: String?
    
    func setClientName(clientName: String) -> EzyClientConfig {
        self.clientName = clientName
        return self
    }
    
    func setZoneName(zoneName: String) -> EzyClientConfig {
        self.zoneName = zoneName
        return self
    }
    
    func setEnableSSL(enableSSL: Bool) -> EzyClientConfig {
        self.enableSSL = enableSSL
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
        return dict
    }
    
}

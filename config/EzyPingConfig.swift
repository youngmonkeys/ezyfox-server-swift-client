//
//  EzyPingConfig.swift
//  freechat-swift
//
//  Created by Dzung on 04/09/2021.
//  Copyright © 2021 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyPingConfig {

    var pingPeriod: Int = 3000
    var maxLostPingCount: Int = 5
    
    func setPingPeriod(pingPeriod: Int) -> EzyPingConfig {
        self.pingPeriod = pingPeriod
        return self
    }
    
    func setMaxLostPingCount(maxLostPingCount: Int) -> EzyPingConfig {
        self.maxLostPingCount = maxLostPingCount
        return self
    }
    
    func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["pingPeriod"] = pingPeriod
        dict["maxLostPingCount"] = maxLostPingCount
        return dict
    }
}

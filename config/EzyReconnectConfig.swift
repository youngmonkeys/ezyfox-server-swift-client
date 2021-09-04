//
//  EzyReconnectConfig.swift
//  freechat-swift
//
//  Created by Dzung on 04/09/2021.
//  Copyright © 2021 Young Monkeys. All rights reserved.
//

import Foundation

public class EzyReconnectConfig {

    var enable: Bool = true
    var maxReconnectCount: Int = 5
    var reconnectPeriod: Int = 3000
    
    func setEnable(enable: Bool) -> EzyReconnectConfig {
        self.enable = enable
        return self
    }
    
    func setMaxReconnectCount(maxReconnectCount: Int) -> EzyReconnectConfig {
        self.maxReconnectCount = maxReconnectCount
        return self
    }
    
    func setReconnectPeriod(reconnectPeriod: Int) -> EzyReconnectConfig {
        self.reconnectPeriod = reconnectPeriod
        return self
    }

    func toDictionary() -> NSDictionary {
        let dict = NSMutableDictionary()
        dict["enable"] = enable
        dict["maxReconnectCount"] = maxReconnectCount
        dict["reconnectPeriod"] = reconnectPeriod
        return dict
    }
}

//
//  EzyLogger.swift
//  freechat-swift
//
//  Created by Dung Ta Van on 8/4/19.
//  Copyright © 2019 Young Monkeys. All rights reserved.
//

import Foundation

class EzyLogger {
    
    public static let LEVEL_DEBUG : UInt8 = 1;
    public static let LEVEL_INFO : UInt8 = 1;
    public static let LEVEL_WARN : UInt8 = 2;
    public static let LEVEL_ERROR : UInt8 = 3;
    
    private static var level : UInt8 = LEVEL_DEBUG;
    
    
    private init() {
    }
    
    public static func setLevel(level: UInt8) {
        EzyLogger.level = level;
    }
    
    public static func debug(msg: String) {
        if(level <= LEVEL_DEBUG) {
            print(standardizedMessage(lv: LEVEL_DEBUG, message: msg));
        }
    }
    
    public static func info(msg: String) {
        if(level <= LEVEL_INFO) {
            print(standardizedMessage(lv: LEVEL_INFO, message: msg));
        }
    }
    
    public static func warn(msg: String) {
        if(level <= LEVEL_WARN) {
            print(standardizedMessage(lv: LEVEL_WARN, message: msg));
        }
    }
    
    public static func error(msg: String) {
        if(level <= LEVEL_ERROR) {
            print(standardizedMessage(lv: LEVEL_ERROR, message: msg));
        }
    }
    
    static func getLevelName(lv: UInt8) -> String {
        switch lv {
        case LEVEL_DEBUG:
            return "DEBUG";
        case LEVEL_INFO:
            return "INFO";
        case LEVEL_WARN:
            return "WARN";
        case LEVEL_ERROR:
            return "ERROR";
        default:
            return "UNKNOWN";
        }
    }
    
    static func standardizedMessage(lv: UInt8, message: String) -> String {
        var builder: String = "";
        builder += getLevelName(lv: lv);
        builder += " | ";
        builder += Thread.current.name!;
        builder += " | ";
        builder += message;
        return builder;
    }
}

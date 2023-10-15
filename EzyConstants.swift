//
//  EzyConstants.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public final class EzySslType {
    private init() {}

    public static let CERTIFICATION = 0
    public static let CUSTOMIZATION = 1;
}

public final class EzyCommand {
    private init() {}
    
    public static let ERROR = "ERROR"
    public static let HANDSHAKE = "HANDSHAKE"
    public static let PING = "PING"
    public static let PONG = "PONG"
    public static let LOGIN = "LOGIN"
    public static let LOGIN_ERROR = "LOGIN_ERROR"
    public static let LOGOUT = "LOGOUT"
    public static let APP_ACCESS = "APP_ACCESS"
    public static let APP_REQUEST = "APP_REQUEST"
    public static let APP_EXIT = "APP_EXIT"
    public static let APP_ACCESS_ERROR = "APP_ACCESS_ERROR"
    public static let APP_REQUEST_ERROR = "APP_REQUEST_ERROR"
    public static let PLUGIN_INFO = "PLUGIN_INFO"
    public static let PLUGIN_REQUEST = "PLUGIN_REQUEST"
}

public final class EzyEventType {
    private init() {}
    
    public static let CONNECTION_SUCCESS = "CONNECTION_SUCCESS"
    public static let CONNECTION_FAILURE = "CONNECTION_FAILURE"
    public static let DISCONNECTION = "DISCONNECTION"
    public static let LOST_PING = "LOST_PING"
    public static let TRY_CONNECT = "TRY_CONNECT"
}

public final class EzyConnectionStatus {
    private init() {}
    
    public static let NULL = "NULL"
    public static let CONNECTING = "CONNECTING"
    public static let CONNECTED = "CONNECTED"
    public static let DISCONNECTED = "DISCONNECTED"
    public static let FAILURE = "FAILURE"
    public static let RECONNECTING = "RECONNECTING"
}

public final class EzyDisconnectReason {
    private init() {}
    
    public static let CLOSE = -1
    public static let UNKNOWN = 0
    public static let IDLE = 1
    public static let NOT_LOGGED_IN = 2
    public static let ANOTHER_SESSION_LOGIN = 3
    public static let ADMIN_BAN = 4
    public static let ADMIN_KICK = 5
    public static let MAX_REQUEST_PER_SECOND = 6
    public static let MAX_REQUEST_SIZE = 7
    public static let SERVER_ERROR = 8
    public static let SERVER_NOT_RESPONDING = 400
    public static let UNAUTHORIZED = 401
}

public final class EzyDisconnectReasons {
    private static let REASON_NAMES = [
        EzyDisconnectReason.CLOSE : "CLOSE",
        EzyDisconnectReason.UNKNOWN : "UNKNOWN",
        EzyDisconnectReason.IDLE : "IDLE",
        EzyDisconnectReason.NOT_LOGGED_IN : "NOT_LOGGED_IN",
        EzyDisconnectReason.ANOTHER_SESSION_LOGIN : "ANOTHER_SESSION_LOGIN",
        EzyDisconnectReason.ADMIN_BAN : "ADMIN_BAN",
        EzyDisconnectReason.ADMIN_KICK : "ADMIN_KICK",
        EzyDisconnectReason.MAX_REQUEST_PER_SECOND : "MAX_REQUEST_PER_SECOND",
        EzyDisconnectReason.MAX_REQUEST_SIZE : "MAX_REQUEST_SIZE",
        EzyDisconnectReason.SERVER_ERROR : "SERVER_ERROR",
        EzyDisconnectReason.SERVER_NOT_RESPONDING : "SERVER_NOT_RESPONDING",
        EzyDisconnectReason.UNAUTHORIZED : "UNAUTHORIZED"
    ]
    private init() {}
    
    public static func getDisconnectReasonName(reasonId: Int) -> String {
        return REASON_NAMES[reasonId, default: String(reasonId)]
    }
}

public final class EzyConnectionFailedReason {
    private init() {}
    
    public static let TIMEOUT = 0
    public static let NETWORK_UNREACHABLE = 1;
    public static let UNKNOWN_HOST = 2;
    public static let CONNECTION_REFUSED = 3;
    public static let UNKNOWN = 4;
}

public final class EzyConnectionFailedReasons {
    private static let REASON_NAMES = [
        EzyConnectionFailedReason.TIMEOUT: "TIMEOUT",
        EzyConnectionFailedReason.NETWORK_UNREACHABLE: "NETWORK_UNREACHABLE",
        EzyConnectionFailedReason.UNKNOWN_HOST: "UNKNOWN_HOST",
        EzyConnectionFailedReason.CONNECTION_REFUSED: "CONNECTION_REFUSED",
        EzyConnectionFailedReason.UNKNOWN: "UNKNOWN"
    ]
    private init() {}
    
    public static func getConnectionFailedReasonName(reasonId: Int) -> String {
        return REASON_NAMES[reasonId, default: String(reasonId)]
    }
}

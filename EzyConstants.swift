//
//  EzyConstants.swift
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

import Foundation

public final class EzyCommand {
    private init() {
    }
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
    public static let PLUGIN_REQUEST_BY_NAME = "PLUGIN_REQUEST_BY_NAME"
    public static let PLUGIN_REQUEST_BY_ID = "PLUGIN_REQUEST_BY_ID"
}

public final class EzyEventType {
    public static let CONNECTION_SUCCESS = "CONNECTION_SUCCESS"
    public static let CONNECTION_FAILURE = "CONNECTION_FAILURE"
    public static let DISCONNECTION = "DISCONNECTION"
    public static let LOST_PING = "LOST_PING"
    public static let TRY_CONNECT = "TRY_CONNECT"
}

public final class EzyConnectionStatus {
    public static let NULL = "NULL"
    public static let CONNECTING = "CONNECTING"
    public static let CONNECTED = "CONNECTED"
    public static let DISCONNECTED = "DISCONNECTED"
    public static let FAILURE = "FAILURE"
    public static let RECONNECTING = "RECONNECTING"
}

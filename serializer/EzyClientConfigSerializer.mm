//
//  EzyClientConfigSerializer.m
//  ezyfox-server-react-native-client
//
//  Created by Dung Ta Van on 10/27/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

#import "EzyClientConfigSerializer.h"
#import "EzyHeaders.h"
#import "../util/EzyNativeStrings.h"

EZY_USING_NAMESPACE::config;

@implementation EzyClientConfigSerializer
- (NSDictionary *)serialize:(void *)value {
    EzyClientConfig* config = (EzyClientConfig*)value;
    NSDictionary* dict = [NSMutableDictionary dictionary];
    [dict setValue:[EzyNativeStrings newNSString:config->getClientName().c_str()] forKey:@"clientName"];
    [dict setValue:[EzyNativeStrings newNSString:config->getZoneName().c_str()] forKey:@"zoneName"];
    
    EzyPingConfig* pingConfig = config->getPing();
    NSDictionary* pingDict = [NSMutableDictionary dictionary];
    [pingDict setValue:[NSNumber numberWithInt:pingConfig->getPingPeriod()] forKey:@"pingPeriod"];
    [pingDict setValue:[NSNumber numberWithInt:pingConfig->getMaxLostPingCount()] forKey:@"maxLostPingCount"];
    [dict setValue:pingDict forKey:@"ping"];
    
    EzyReconnectConfig* reconnectConfig = config->getReconnect();
    NSDictionary* reconnectDict = [NSMutableDictionary dictionary];
    [reconnectDict setValue:[NSNumber numberWithInt:reconnectConfig->getMaxReconnectCount()] forKey:@"maxReconnectCount"];
    [reconnectDict setValue:[NSNumber numberWithInt:reconnectConfig->getReconnectPeriod()] forKey:@"reconnectPeriod"];
    [reconnectDict setValue:[NSNumber numberWithInt:reconnectConfig->isEnable()] forKey:@"enable"];
    [dict setValue:reconnectDict forKey:@"reconnect"];
    
    return dict;
}
@end

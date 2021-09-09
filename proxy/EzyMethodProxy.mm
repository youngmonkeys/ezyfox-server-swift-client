//
//  EzyMethodProxy.m
//  ezyfox-server-react-native-client
//
//  Created by Dung Ta Van on 10/26/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

#include <map>
#include <string>
#include "EzyHeaders.h"
#import "EzyMethodProxy.h"
#import "../EzyMethodNames.h"
#import "../util/EzyNativeStrings.h"
#import "../serializer/EzyNativeSerializers.h"
#import "../EzyEventEmitter.h"

EZY_USING_NAMESPACE;
EZY_USING_NAMESPACE::config;
EZY_USING_NAMESPACE::setup;
EZY_USING_NAMESPACE::constant;
EZY_USING_NAMESPACE::event;
EZY_USING_NAMESPACE::handler;
EZY_USING_NAMESPACE::entity;
EZY_USING_NAMESPACE::socket;

static std::map<EzyEventType, std::string> sNativeEventTypeNames = {
    {ConnectionSuccess, "CONNECTION_SUCCESS"},
    {ConnectionFailure, "CONNECTION_FAILURE"},
    {Disconnection, "DISCONNECTION"},
    {LostPing, "LOST_PING"},
    {TryConnect, "TRY_CONNECT"}
};

static std::map<EzyCommand, std::string> sNativeCommandNames = {
    {Error, "ERROR"},
    {Handshake, "HANDSHAKE"},
    {Ping, "PING"},
    {Pong, "PONG"},
    {Disconnect, "DISCONNECT"},
    {Login, "LOGIN"},
    {LoginError, "LOGIN_ERROR"},
    {AppAccess, "APP_ACCESS"},
    {AppRequest, "APP_REQUEST"},
    {AppExit, "APP_EXIT"},
    {AppAccessError, "APP_ACCESS_ERROR"},
    {AppRequestError, "APP_REQUEST_ERROR"},
    {PluginInfo, "PLUGIN_INFO"},
    {PluginRequest, "PLUGIN_REQUEST"}
};

static std::map<std::string, EzyCommand> sNativeCommandIds = {
    {"ERROR", Error},
    {"HANDSHAKE", Handshake},
    {"PING", Ping},
    {"PONG", Pong},
    {"DISCONNECT", Disconnect},
    {"LOGIN", Login},
    {"LOGIN_ERROR", LoginError},
    {"APP_ACCESS", AppAccess},
    {"APP_REQUEST", AppRequest},
    {"APP_EXIT", AppExit},
    {"APP_ACCESS_ERROR", AppAccessError},
    {"APP_REQUEST_ERROR", AppRequestError},
    {"PLUGIN_INFO", PluginInfo},
    {"PLUGIN_REQUEST", PluginRequest}
};

static std::map<std::string, EzyConnectionStatus> sNativeConnectionStatusIds = {
    {"NULL", Null},
    {"CONNECTING", Connecting},
    {"CONNECTED", Connected},
    {"DISCONNECTED", Disconnected},
    {"FAILURE", Failure},
    {"RECONNECTING", Reconnecting}
};

//======================================================

EzyClients* clients = EzyClients::getInstance();

EzyClient* getClient(std::string name) {
    EzyClient* client = clients->getClient(name);
    return client;
}

EzyClient* getClient(NSString* name) {
    EzyClient* client = getClient([name UTF8String]);
    return client;
}

EzyClient* getClient(NSDictionary* params) {
    NSString* clientName = [params valueForKey:@"clientName"];
    if(!clientName)
        [NSException raise:NSInvalidArgumentException format:@"must specific client name"];
    EzyClient* client = getClient(clientName);
    return client;
}

EzyClientConfig* newConfig(NSDictionary* params) {
    EzyClientConfig* config = EzyClientConfig::create();
    NSString* clientName = [params valueForKey:@"clientName"];
    NSString* zoneName = [params valueForKey:@"zoneName"];
    NSDictionary* ping = [params valueForKey:@"ping"];
    NSDictionary* reconnect = [params valueForKey:@"reconnect"];
    if(clientName)
        config->setClientName([clientName UTF8String]);
    if(zoneName)
        config->setZoneName([zoneName UTF8String]);
    if(ping) {
        NSNumber* pingPeriod = [ping objectForKey:@"pingPeriod"];
        NSNumber* maxLostPingCount = [ping objectForKey:@"maxLostPingCount"];
        EzyPingConfig* pingConfig = config->getPing();
        if(pingPeriod) {
            pingConfig->setPingPeriod((int)[pingPeriod integerValue]);
        }
        if(maxLostPingCount) {
            pingConfig->setMaxLostPingCount((int)[maxLostPingCount integerValue]);
        }
    }
    if(reconnect) {
        NSNumber* enable = [reconnect objectForKey:@"enable"];
        NSNumber* reconnectPeriod = [reconnect objectForKey:@"reconnectPeriod"];
        NSNumber* maxReconnectCount = [reconnect objectForKey:@"maxReconnectCount"];
        EzyReconnectConfig* reconnectConfig = config->getReconnect();
        if(enable)
            reconnectConfig->setEnable([enable boolValue]);
        if(reconnectConfig)
            reconnectConfig->setReconnectPeriod((int)[reconnectPeriod integerValue]);
        if(maxReconnectCount)
            reconnectConfig->setMaxReconnectCount((int)[maxReconnectCount integerValue]);
    }
    return config;
}

//======================================================

class EzyNativeEventHandler :  public EzyEventHandler {
private:
    EzyClient* mClient;
    EzyEventEmitter* mEventEmitter;
public:
    EzyNativeEventHandler(EzyClient* client) {
        this->mClient = client;
        this->mEventEmitter = [EzyEventEmitter getInstance];
    }
    ~EzyNativeEventHandler() {
        this->mClient = 0;
        this->mEventEmitter = 0;
    }
public:
    void handle(EzyEvent* event) {
        std::string eventTypeName = sNativeEventTypeNames[event->getType()];
        NSDictionary* params = [NSMutableDictionary dictionary];
        NSDictionary* eventData = [EzyNativeSerializers serializeEvent:event];
        [params setValue:[EzyNativeStrings newNSString:mClient->getName().c_str()] forKey:@"clientName"];
        [params setValue:[EzyNativeStrings newNSString:eventTypeName.c_str()] forKey:@"eventType"];
        [params setValue:eventData forKey:@"data"];
        [mEventEmitter sendEventWithName:@"ezy.event" body:params];
    }
};

class EzyNativeDataHandler : public EzyDataHandler {
private:
    EzyClient* mClient;
    EzyEventEmitter* mEventEmitter;
    EzyCommand mCommand;
public:
    EzyNativeDataHandler(EzyClient* client, EzyCommand command) {
        this->mClient = client;
        this->mCommand = command;
        this->mEventEmitter = [EzyEventEmitter getInstance];
    }
    ~EzyNativeDataHandler() {
        this->mClient = 0;
        this->mEventEmitter = 0;
    }
public:
    void handle(entity::EzyArray* data) {
        std::string commandName = sNativeCommandNames[mCommand];
        NSDictionary* params = [NSMutableDictionary dictionary];
        NSArray* commandData = [EzyNativeSerializers toWritableArray:data];
        [params setValue:[EzyNativeStrings newNSString:mClient->getName().c_str()] forKey:@"clientName"];
        [params setValue:[EzyNativeStrings newNSString:commandName.c_str()] forKey:@"command"];
        [params setValue:commandData forKey:@"data"];
        [mEventEmitter sendEventWithName:@"ezy.data" body:params];
    }
};

//======================================================
@interface EzyEventsProcessingLoop : NSObject
+ (instancetype)getInstance;
-(void)start;
-(void)stop;
@end

@implementation EzyEventsProcessingLoop {
    volatile bool active;
    EzyClients* mClients;
    std::vector<EzyClient*> mCachedClients;
}

+ (instancetype)getInstance {
    static EzyEventsProcessingLoop *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[EzyEventsProcessingLoop alloc] init];
    });
    return sInstance;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        active = false;
        mCachedClients.clear();
        mClients = EzyClients::getInstance();
    }
    return self;
}

-(void) start {
    if(active) {
        logger::log("events processing loop has already started");
        return;
    }
    active = true;
    NSThread* thread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(loop)
                                                 object:nil];
    [thread start];
}

-(void) stop {
    active = false;
}

-(void) loop {
    while (active) {
        [[NSThread currentThread] setName:@"ezyfox-process-event"];
        dispatch_sync(dispatch_get_main_queue(), ^(void) {
            self->mClients->getClients(self->mCachedClients);
            for(int i = 0 ; i < self->mCachedClients.size() ; ++i) {
                EzyClient* client = self->mCachedClients[i];
                client->processEvents();
            }
        });
        [NSThread sleepForTimeInterval:0.003];
    }
}

@end

//======================================================

@implementation EzyMethodProxy
-(void)validate:(NSDictionary *)params {}
-(NSObject*)invoke: (NSDictionary*) params {return nil;}
-(NSString*)getName {return nil;}
@end

//======================================================
@implementation EzyCreateClientMethod

-(void)validate:(NSDictionary *)params {
    if(!params)
        [NSException raise:NSInvalidArgumentException format:@"the config is null, can't create an client"];
}

-(NSObject*)invoke:(NSDictionary *)params {
    EzyClientConfig* config = newConfig(params);
    EzyClient* client = getClient(config->getClientName());
    if(!client) {
        client = clients->newClient(config);
        [self setupClient:client];
    }
    NSDictionary* configMap = [EzyNativeSerializers serializeClientConfig:config];
    return configMap;
}

-(void) setupClient:(EzyClient*)client {
    EzySetup* setup = client->setup();
    for(int i = 1 ; i <= NUMBER_OF_EVENTS ; ++i) {
        EzyEventType eventType = (EzyEventType)i;
        setup->addEventHandler(eventType, new EzyNativeEventHandler(client));
    }
    for(int i = 0 ; i < NUMBER_OF_COMMANDS ; ++i) {
        EzyCommand command = (EzyCommand)sCommands[i];
        setup->addDataHandler(command, new EzyNativeDataHandler(client, command));
    }
}

- (NSString *)getName {
    return METHOD_INIT;
}
@end

//======================================================
@implementation EzyConnectMethod

-(void)validate:(NSDictionary *)params {
    if(![params valueForKey:@"host"])
        [NSException raise:NSInvalidArgumentException format:@"must specific host"];
    if(![params valueForKey:@"port"])
        [NSException raise:NSInvalidArgumentException format:@"must specific port"];
}

- (NSObject *)invoke:(NSDictionary *)params {
    NSString* host = [params valueForKey:@"host"];
    NSNumber* port = [params valueForKey:@"port"];
    EzyClient* client = getClient(params);
    client->connect([host UTF8String], [port intValue]);
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_CONNECT;
}

@end

//======================================================
@implementation EzyReconnectMethod

- (NSObject *)invoke:(NSDictionary *)params {
    EzyClient* client = getClient(params);
    bool answer = client->reconnect();
    return [NSNumber numberWithBool:answer];
}

- (NSString *)getName {
    return METHOD_RECONNECT;
}
@end

//======================================================
@implementation EzyDisconnectMethod

- (NSObject *)invoke:(NSDictionary *)params {
    EzyClient* client = getClient(params);
    int reason = 0;
    if([params valueForKey:@"reason"])
        reason = [[params valueForKey:@"reason"] intValue];
    client->disconnect(reason);
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_DISCONNECT;
}
@end

//======================================================
@implementation EzySendMethod

- (NSObject *)invoke:(NSDictionary *)params {
    NSDictionary* request = [params objectForKey:@"request"];
    if(!request) {
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException"
                                       reason:@"must specific request to send to server"
                                     userInfo:nil];
    }
    EzyClient* client = getClient(params);
    NSString* cmd = [request objectForKey:@"command"];
    NSArray* data = [request objectForKey:@"data"];
    NSNumber* encrypted = [request objectForKey:@"encrypted"];
    EzyArray* array = (EzyArray*)[EzyNativeSerializers fromReadableArray:data];
    EzyCommand command = sNativeCommandIds[[cmd UTF8String]];
    client->send(command, array, encrypted.boolValue);
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_SEND;
}
@end

//======================================================
@implementation EzySetStatusMethod

- (NSObject *)invoke:(NSDictionary *)params {
    EzyClient* client = getClient(params);
    NSString* statusName = [params valueForKey:@"status"];
    EzyConnectionStatus status = sNativeConnectionStatusIds[[statusName UTF8String]];
    client->setStatus(status);
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_SET_STATUS;
}
@end

//======================================================
@implementation EzySetSessionKeyMethod

- (NSObject *)invoke:(NSDictionary *)params {
    EzyClient* client = getClient(params);
    NSData* sessionKeyData = [params valueForKey:@"sessionKey"];
    std::string sessionKey = std::string((char*)sessionKeyData.bytes, sessionKeyData.length);
    client->setSessionKey(sessionKey);
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_SET_SESSION_KEY;
}
@end

//======================================================
@implementation EzyStartPingScheduleMethod

- (NSObject *)invoke:(NSDictionary *)params {
    EzyClient* client = getClient(params);
    EzyPingSchedule* pingSchedule = client->getPingSchedule();
    pingSchedule->start();
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_START_PING_SCHEDULE;
}
@end

//======================================================
@implementation EzyProcessEventsMethod

- (NSObject *)invoke:(NSDictionary *)params {
    [[EzyEventsProcessingLoop getInstance] start];
    return [NSNumber numberWithBool:TRUE];
}

- (NSString *)getName {
    return METHOD_PROCESS_EVENTS;
}
@end

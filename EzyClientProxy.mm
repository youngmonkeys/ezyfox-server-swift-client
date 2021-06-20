//
//  EzyClientProxy.m
//  ezyfox-server-react-native-client
//
//  Created by Dung Ta Van on 10/26/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

#import "EzyClientProxy.h"
#import "proxy/EzyMethodProxy.h"
#import "exception/EzyMethodCallException.h"

@implementation EzyClientProxy {
    NSDictionary<NSString*, EzyMethodProxy*>* _methods;
}

+ (instancetype)getInstance {
    static EzyClientProxy *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[EzyClientProxy alloc] init];
    });
    return sInstance;
}

-(instancetype)init {
    self = [super init];
    if(self) {
        _methods = [NSMutableDictionary dictionary];
        [self initMethods];
    }
    return self;
}

-(void)initMethods {
    [self addMethod:[[EzyCreateClientMethod alloc]init]];
    [self addMethod:[[EzyConnectMethod alloc]init]];
    [self addMethod:[[EzyDisconnectMethod alloc]init]];
    [self addMethod:[[EzySendMethod alloc]init]];
    [self addMethod:[[EzyReconnectMethod alloc]init]];
    [self addMethod:[[EzySetStatusMethod alloc]init]];
    [self addMethod:[[EzyStartPingScheduleMethod alloc]init]];
    [self addMethod:[[EzyProcessEventsMethod alloc]init]];
    [self addMethod:[[EzySetSessionKeyMethod alloc]init]];
}

-(void)addMethod:(EzyMethodProxy*)method {
    [_methods setValue:method forKey:[method getName]];
}

-(NSObject*)run:(NSString*)method params:(NSDictionary*)params {
    EzyMethodProxy* func = [_methods valueForKey:method];
    if(!func) {
        NSString* exceptionReason = [NSString stringWithFormat:@"has no method: %@", method];
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException" reason:exceptionReason userInfo:nil];
    }
    @try {
        [func validate:params];
        NSObject* result = [func invoke:params];
        return result;
    }
    @catch (NSException* e) {
        NSLog(@"call method: %@ with params %@ fatal error: %@", method, params, [e reason]);
        @throw e;
    }
}

@end

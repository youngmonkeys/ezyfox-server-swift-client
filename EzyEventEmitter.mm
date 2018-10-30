//
//  EzyEventEmitter.m
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

#import "EzyEventEmitter.h"

@implementation EzyEventEmitter {
    NSDictionary<NSDictionary*, EzyEventListenerBlock> *_eventListener;
}

+ (instancetype)getInstance {
    static EzyEventEmitter *sInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[EzyEventEmitter alloc] init];
    });
    return sInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _eventListener = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)sendEventWithName:(NSString *)name body:(NSDictionary *)body {
    EzyEventListenerBlock listener = [_eventListener valueForKey:name];
    if(listener)
        listener(body);
    [NSException raise:NSInvalidArgumentException format:@"has no lister with event name: %@", name];
}

- (void)setEventListener:(NSString *)name listener:(EzyEventListenerBlock)listener {
    [_eventListener setValue:listener forKey:name];
}

@end

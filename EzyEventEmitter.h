//
//  EzyEventEmitter.h
//  hello-swift
//
//  Created by Dung Ta Van on 10/30/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^EzyEventListenerBlock)(NSDictionary*);

@interface EzyEventEmitter : NSObject
+(instancetype)getInstance;
-(void)sendEventWithName:(NSString*)name body:(NSDictionary*)body;
-(void)setEventListener:(NSString*)name listener:(EzyEventListenerBlock)listener;
@end

NS_ASSUME_NONNULL_END

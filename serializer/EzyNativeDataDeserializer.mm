//
//  EzyNativeDataDeserializer.m
//  ezyfox-server-react-native-client
//
//  Created by Dung Ta Van on 10/27/18.
//  Copyright © 2018 Young Monkeys. All rights reserved.
//

#import "EzyNativeDataDeserializer.h"
#import "../math/EzyNSNumber.h"
#import "../util/NSByteArray.h"
#include "EzyHeaders.h"

EZY_USING_NAMESPACE::entity;

@implementation EzyNativeDataDeserializer
- (void *)fromReadableArray:(NSArray *)value {
    EzyArray* array = new EzyArray();
    if(value) {
        for(id item in value)
            [self deserializeToArray:array value:item];
    }
    return array;
}

- (void *) fromReadableMap: (NSDictionary*)value {
    EzyObject* object = new EzyObject();
    if(value) {
        for(id key in value) {
            NSObject* val = [value valueForKey:key];
            [self deserializeToObject:object key:key value:val];
        }
    }
    return object;
}

- (void)deserializeToArray:(EzyArray*)output value:(NSObject*)value {
    if([value isKindOfClass:[NSNumber class]]) {
        EzyPrimitive* item = [self deserializeToPrimitive:value];
        output->addItem(item);
    }
    else if([value isKindOfClass:[EzyNSNumber class]]) {
        EzyNSNumber* number = (EzyNSNumber*)value;
        EzyPrimitive* item = [self deserializeToNumber:number];
        output->addItem(item);
    }
    else if([value isKindOfClass:[NSString class]]) {
        NSString* string = (NSString*)value;
        output->addString([string UTF8String]);
    }
    else if([value isKindOfClass:[NSByteArray class]]) {
        NSByteArray* byteArray = (NSByteArray*)value;
        output->addByteArray(std::string((char*)byteArray.data.bytes, byteArray.size));
    }
    else if([value isKindOfClass:[NSArray class]]) {
        NSArray* array = (NSArray*)value;
        EzyArray* farray = (EzyArray*)[self fromReadableArray:array];
        output->addArray(farray);
    }
    else if([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*)value;
        EzyObject* fobject = (EzyObject*)[self fromReadableMap:dict];
        output->addObject(fobject);
    }
    else if([value isKindOfClass:[NSNull class]]) {
        output->addNull();
    }
    else {
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException"
                                       reason: [NSString stringWithFormat:@"has no deserializer for value: %@", value]
                                     userInfo:nil];
    }
}

- (void)deserializeToObject:(EzyObject*)output key:(NSString*)key value:(NSObject*)value {
    std::string k = [key UTF8String];
    if([value isKindOfClass:[NSNumber class]]) {
        EzyPrimitive* item = [self deserializeToPrimitive:value];
        output->addItem(k, item);
    }
    else if([value isKindOfClass:[EzyNSNumber class]]) {
        EzyNSNumber* number = (EzyNSNumber*)value;
        EzyPrimitive* item = [self deserializeToNumber:number];
        output->addItem(k, item);
    }
    else if([value isKindOfClass:[NSString class]]) {
        NSString* string = (NSString*)value;
        output->setString(k, [string UTF8String]);
    }
    else if([value isKindOfClass:[NSArray class]]) {
        NSArray* array = (NSArray*)value;
        EzyArray* farray = (EzyArray*)[self fromReadableArray:array];
        output->setArray(k, farray);
    }
    else if([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary* dict = (NSDictionary*)value;
        EzyObject* fobject = (EzyObject*)[self fromReadableMap:dict];
        output->setObject(k, fobject);
    }
    else {
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException"
                                       reason: [NSString stringWithFormat:@"has no deserializer for key: %@, value: %@", key, value]
                                     userInfo:nil];
    }
}

-(EzyPrimitive*)deserializeToNumber:(EzyNSNumber*)value {
    EzyPrimitive* item = new EzyPrimitive();
    switch ([value getType]) {
        case NUMBER_TYPE_BOOL:
            item->setBool([value boolValue]);
            break;
        case NUMBER_TYPE_DOUBLE:
            item->setDouble([value doubleValue]);
            break;
        case NUMBER_TYPE_FLOAT:
            item->setFloat([value floatValue]);
            break;
        case NUMBER_TYPE_INT:
            item->setInt([value intValue]);
            break;
        case NUMBER_TYPE_UINT:
            item->setInt([value uintValue]);
            break;
        default:
            break;
    }
    return item;
};

-(EzyPrimitive*)deserializeToPrimitive:(NSObject*)value {
    NSNumber* number = (NSNumber*)value;
    EzyPrimitive* item = new EzyPrimitive();
    CFNumberType numberType = CFNumberGetType((CFNumberRef)number);
    if(numberType == kCFNumberSInt8Type) {
        item->setInt([number intValue]);
    }
    else if(numberType == kCFNumberSInt16Type) {
        item->setInt([number intValue]);
    }
    else if(numberType == kCFNumberSInt32Type) {
        item->setInt([number longValue]);
    }
    else if(numberType == kCFNumberSInt64Type) {
        item->setInt([number longLongValue]);
    }
    else if(numberType == kCFNumberFloat32Type) {
        item->setInt([number floatValue]);
    }
    else if(numberType == kCFNumberFloat64Type) {
        item->setInt([number doubleValue]);
    }
    else if(numberType == kCFNumberCharType) {
        if([number isEqual: @(YES)] || [number isEqual: @(NO)]) {
            item->setBool([number boolValue]);
        }
        else {
            item->setInt([number intValue]);
        }
    }
    else if(numberType == kCFNumberShortType) {
        item->setInt([number intValue]);
    }
    else if(numberType == kCFNumberIntType) {
        item->setInt([number longValue]);
    }
    else if(numberType == kCFNumberLongType) {
        item->setInt([number longLongValue]);
    }
    else if(numberType == kCFNumberLongLongType) {
        item->setInt([number longLongValue]);
    }
    else if(numberType == kCFNumberFloatType) {
        item->setInt([number floatValue]);
    }
    else if(numberType == kCFNumberDoubleType) {
        item->setInt([number doubleValue]);
    }
    else if(numberType == kCFNumberCFIndexType) {
        item->setInt([number longLongValue]);
    }
    else if(numberType == kCFNumberNSIntegerType) {
        item->setInt([number longLongValue]);
    }
    else if(numberType == kCFNumberCGFloatType) {
        item->setInt([number floatValue]);
    }
    else if(numberType == kCFNumberMaxType) {
        item->setInt([number longLongValue]);
    }
    else {
        @throw [NSException exceptionWithName:@"NSInvalidArgumentException"
                                       reason: [NSString stringWithFormat:@"can deserialize number: %@ with type: %d", number, (int)numberType]
                                     userInfo:nil];
    }
    return item;
};
@end

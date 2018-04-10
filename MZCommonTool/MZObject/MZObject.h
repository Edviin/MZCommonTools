//
//  MZObject.h
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
@protocol MZ_Object <NSObject>
+ (nullable instancetype)serializeWithJsonObject:(nullable NSDictionary *)jsonObj;
- (nullable instancetype)initWithJsonObject:(nullable NSDictionary *)jsonObj;
- (nonnull NSDictionary *)toJsonObject;
@end

@interface MZObject : NSObject <MZ_Object, NSCopying, NSCoding>
+ (nullable instancetype)serializeWithJsonObject:(nullable NSDictionary *)jsonObj;
+ (nullable NSMutableArray *)serializeWithJsonObjects:(nullable NSArray *)jsonObjects;

- (nullable instancetype)init;
- (nullable instancetype)initWithJsonObject:(nullable NSDictionary *)jsonObj;
- (nonnull NSDictionary *)toJsonObject;
@end

#define MZ_Generic_Custom_Array_Class_Define(__className) \
\
@protocol __className<NSObject>\
\
@end \

#define MZ_Generic_Custom_Array_Class_Implement(__className) //Do nothing

#define MZMObjectArray(__className)         NSArray<__className *><__className>
#define MZMObjectMutableArray(__className)  NSMutableArray<__className *><__className>

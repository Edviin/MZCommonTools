//
//  MZ_HttpRequest.h
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZ_HttpRequest : NSObject
@property (nonatomic, strong, readonly) NSString * url;
@property (nonatomic, strong, readonly) NSDictionary * header;
@property (nonatomic, strong,readwrite) NSDictionary *  data;


- (instancetype)initWithURL:(NSString *)url Header:(NSDictionary *)header Data:(NSDictionary *)data;
+(instancetype)copyWithRequest:(MZ_HttpRequest *)request;
@end

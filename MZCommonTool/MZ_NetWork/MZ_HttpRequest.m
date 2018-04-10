//
//  MZ_HttpRequest.m
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import "MZ_HttpRequest.h"

@implementation MZ_HttpRequest
-(instancetype) initWithURL:(NSString *)url Header:(NSDictionary *)header Data:(NSDictionary *)data{
    if (self = [super init]) {
        _url = url;
        _header = header;
        _data = data;
        
    }
    return self;
}

+(instancetype)copyWithRequest:(MZ_HttpRequest *)request{
    MZ_HttpRequest *newRequest=[[MZ_HttpRequest alloc]initWithURL:request.url Header:request.header Data:request.data ];
    return  newRequest;
}
@end

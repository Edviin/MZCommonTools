//
//  MZ_HttpImageRequest.m
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import "MZ_HttpImageRequest.h"
@implementation MZ_HttpImageData
-(instancetype) initWithData:(NSData *)data  name:(NSString *)name FileName:(NSString *)fileName{
    if(self = [super init]){
        _data = data;
        _name = name;
        _fileName = fileName;
        
    }
    return self;
}
@end
@implementation MZ_HttpImageRequest
-(instancetype)initWithURL:(NSString *)url Header:(NSDictionary *)header Data:(NSDictionary *)data andImageArr:(NSArray <MZ_HttpImageData *>*)imagesArr{
    if (self = [super initWithURL:url Header:header Data:data]) {
        _imagesArr = imagesArr;
    }
    return self;
}

+(instancetype)copyWithRequest:(MZ_HttpImageRequest *)request{
    MZ_HttpImageRequest *newRequest=[[MZ_HttpImageRequest alloc]initWithURL:request.url Header:request.header Data:request.data  andImageArr:request.imagesArr ];
    return  newRequest;
}
@end

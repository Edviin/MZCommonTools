//
//  MZ_HttpResponse.m
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import "MZ_HttpResponse.h"

@implementation MZ_HttpResponse
-(instancetype) initWithHeader:(NSDictionary *)header Data:(id)data{
    if(self = [super init]){
        _header = header;
        _data = data;
        if ([_data isKindOfClass:[NSDictionary class]]) {
            _json = data;
        }
    }
    return self;
}

- (NSDictionary *)json
{
    if(_json) return _json;
    
    if(_data) {
        
        NSError * error;
        _json = [NSJSONSerialization JSONObjectWithData:_data options:kNilOptions error:&error];
        
        if(error) return nil;
        return _json;
    }
    
    return nil;
}
@end

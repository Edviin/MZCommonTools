//
//  MZ_HttpResponse.h
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZ_HttpResponse : NSObject
@property (nonatomic, copy) NSDictionary * header;

@property (nonatomic, copy) id data;

@property (nonatomic, copy) NSDictionary * json;

- (instancetype)initWithHeader:(NSDictionary *)header Data:(id)data;

@end

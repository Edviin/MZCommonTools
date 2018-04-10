//
//  MZ_HttpCoreManager.h
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MZCoreManagerRestTaskCompletion)(id  retObject, NSError *  error);
//全局Handler返回YES则中断处理，返回NO则继续下一步处理
typedef BOOL (^MZCoreManagerRestTaskGlobalCompletionHandler)(id  retObject, NSError *  error);
typedef BOOL (^MZCoreManagerRestTaskGlobalErrorHandler)(id  retObject, NSError *  error);

#ifdef DEBUG
static NSString  *  const  kDCHost_Rest_Master = @"http://qyxtest.chinayanghe.com/yh-smp-rest/";
#else
static NSString * const kDCHost_Rest_Master = @"http://portal.chinayanghe.com/yh-smp-rest/";
#endif


@interface MZ_HttpCoreManager : NSObject
@property (nonatomic, strong, readonly) NSString * host;


//全局接口错误处理回调Block
@property (nonatomic, assign, readonly) MZCoreManagerRestTaskGlobalErrorHandler globalErrorHandler;
//全局接口处理回调Block
@property (nonatomic, assign, readonly) MZCoreManagerRestTaskGlobalCompletionHandler globalCompletionHandler;

// 设置全局接口错误处理回调Block
- (void)setGlobalErrorHandlerWithHandler:( MZCoreManagerRestTaskGlobalErrorHandler)handler;
//设置全局接口处理回调Block
- (void)setGlobalCompletionHandlerWithHandler:( MZCoreManagerRestTaskGlobalCompletionHandler)handler;
@end

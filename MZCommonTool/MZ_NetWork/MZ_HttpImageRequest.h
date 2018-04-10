//
//  MZ_HttpImageRequest.h
//  MZCommonTool
//
//  Created by WMZ on 2018/4/10.
//  Copyright © 2018年 WMZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZ_HttpRequest.h"
@interface MZ_HttpImageData : NSObject

/*
 *该方法的参数
 1. appendPartWithFileData：要上传的照片[二进制流]
 2. name：对应网站上[upload.php中]处理文件的字段（比如upload）
 3. fileName：要保存在服务器上的文件名
 4. mimeType：上传的文件的类型
 */
@property(nonatomic,strong)NSData *data;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *fileName;

-(instancetype) initWithData:(NSData *)data  name:(NSString *)name FileName:(NSString *)fileName;
@end

@interface MZ_HttpImageRequest : MZ_HttpRequest
@property(nonatomic,strong)NSArray<MZ_HttpImageData *> *imagesArr;

-(instancetype)initWithURL:(NSString *)url Header:(NSDictionary *)header Data:(NSDictionary *)data andImageArr:(NSArray <MZ_HttpImageData *>*)imagesArr;
+(instancetype)copyWithRequest:(MZ_HttpImageRequest *)request;
@end

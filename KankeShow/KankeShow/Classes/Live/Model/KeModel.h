//
//  KeModel.h
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYModel.h"

@interface KeModel : NSObject<YYModel>

+ (instancetype)kk_modelWithDict:(NSDictionary *)dict;

@end

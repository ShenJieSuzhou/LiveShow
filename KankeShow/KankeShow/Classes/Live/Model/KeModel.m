//
//  KeModel.m
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import "KeModel.h"

@implementation KeModel

+ (instancetype)kk_modelWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict{
    if(self = [super init]){
        self = [object_getClass(self) yy_modelWithDictionary:dict];
    }
    return self;
}

@end

//
//  SceneModle.m
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import "SceneModle.h"

@implementation SceneModle

+(NSDictionary<NSString *,id> *)modelCustomPropertyMapper
{
    return @{ @"scene_id" : @"id" };
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.title_pic = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title_pic))];
        self.zip_path_ios = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(zip_path_ios))];
        self.create_time = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(create_time))];
        self.scene_id = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(scene_id))];
        self.is_delete = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(is_delete))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.title_pic forKey:NSStringFromSelector(@selector(title_pic))];
    [aCoder encodeObject:self.zip_path_ios forKey:NSStringFromSelector(@selector(zip_path_ios))];
    [aCoder encodeObject:self.create_time forKey:NSStringFromSelector(@selector(create_time))];
    [aCoder encodeObject:self.scene_id forKey:NSStringFromSelector(@selector(scene_id))];
    [aCoder encodeBool:self.is_delete forKey:NSStringFromSelector(@selector(is_delete))];
}

@end

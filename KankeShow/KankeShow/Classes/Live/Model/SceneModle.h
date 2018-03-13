//
//  SceneModle.h
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeModel.h"

@interface SceneModle : KeModel<NSCoding>
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* title_pic;
@property (nonatomic, copy) NSString* create_time;
@property (nonatomic, copy) NSString* scene_id;
@property (nonatomic, copy) NSString* zip_path_ios;
@property (nonatomic, assign) BOOL is_delete;
@property (nonatomic,assign) BOOL is_downloading;
@property (nonatomic, assign) BOOL is_empty;
@end

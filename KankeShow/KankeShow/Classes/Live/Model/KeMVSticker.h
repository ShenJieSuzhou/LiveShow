//
//  KeMVSticker.h
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeModel.h"

@interface KeMVSticker : KeModel
@property (nonatomic,copy) NSString *sticker_directory;
@property (nonatomic,copy) NSString *filename_format;
@property (nonatomic,assign) int frame_count;
@property (nonatomic,assign) float positionX;
@property (nonatomic,assign) float positionY;
@property (nonatomic,assign) float anchorpointX;
@property (nonatomic,assign) float anchorpointY;
@property (nonatomic,assign) float width;
@property (nonatomic,assign) float height;
@property (nonatomic,assign) float display_width;
@property (nonatomic,assign) float display_height;
@property (nonatomic,assign) float animation_duration;
@end

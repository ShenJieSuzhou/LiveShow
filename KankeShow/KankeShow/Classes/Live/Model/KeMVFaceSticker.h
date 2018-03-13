//
//  KeMVFaceSticker.h
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeModel.h"

typedef NS_ENUM(NSInteger, MVStickerFaceType) {
    MVStickerFaceTypeNone = 0,
    MVStickerFaceTypeHead,
    MVStickerFaceTypeEye,
    MVStickerFaceTypeNose,
    MVStickerFaceTypeMouth
};
@interface KeMVFaceSticker : KeModel

@property (nonatomic, copy) NSString* sticker_directory;
@property (nonatomic, copy) NSString* filename_format;
@property (nonatomic, assign) int frame_count;
@property (nonatomic, assign) float anchorpointX;
@property (nonatomic, assign) float anchorpointY;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) float animation_duration;
@property (nonatomic, assign) MVStickerFaceType faceType;
@property (nonatomic, copy) NSString* face_type;

@end

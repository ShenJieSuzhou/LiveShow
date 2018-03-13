//
//  KeMVFaceSticker.m
//  KankeShow
//
//  Created by shenjie on 2018/3/13.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import "KeMVFaceSticker.h"

@implementation KeMVFaceSticker

+ (instancetype)bp_modelWithDict:(NSDictionary*)dict
{
    KeMVFaceSticker* sticker = [super kk_modelWithDict:dict];
    if ([sticker.face_type isEqualToString:@"head"]) {
        sticker.faceType = MVStickerFaceTypeHead;
    } else if ([sticker.face_type isEqualToString:@"eye"]) {
        sticker.faceType = MVStickerFaceTypeEye;
    } else if ([sticker.face_type isEqualToString:@"nose"]) {
        sticker.faceType = MVStickerFaceTypeNose;
    } else if ([sticker.face_type isEqualToString:@"mouth"]) {
        sticker.faceType = MVStickerFaceTypeMouth;
    }
    return sticker;
}

@end

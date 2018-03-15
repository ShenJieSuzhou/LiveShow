//
//  ShowTimeViewController.m
//  KankeShow
//
//  Created by shenjie on 2018/2/27.
//  Copyright © 2018年 shenjie. All rights reserved.
//

#import "ShowTimeViewController.h"
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <GPUImage/GPUImage.h>
#import "GPUImageBeautifyFilter.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import <iflyMSC/IFlyFaceSDK.h>
#import "IFlyFaceImage.h"
#import "CaptureManager.h"
#import "IFlyFaceResultKeys.h"
#import "CanvasView.h"
#import "CalculatorTools.h"
#import "Macrodefines.h"

#import "SceneModle.h"
#import "SSZipArchive.h"


#define MS_WIDTH [UIScreen mainScreen].bounds.size.width
#define MS_HEIGHT [UIScreen mainScreen].bounds.size.height
#define TOP_COVER_HEIGHT 60
#define BOTTOM_COVER_HEIGHT 100

@interface ShowTimeViewController ()<GPUImageVideoCameraDelegate>
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *switchCamare;
@property (nonatomic, strong) UIButton *shotBtn;
@property (nonatomic, strong) UIButton *stopRecord;

@property (nonatomic, strong) UIView *buttomCoverView;
@property (nonatomic, strong) UIView *topCoverView;
@property (nonatomic, strong) UIImageView *photoPreviewView;

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;
@property (nonatomic, strong) GPUImageMovieWriter *movieWriter;
@property (nonatomic, strong) NSString *pathToMovie;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;


@property (nonatomic, retain) IFlyFaceDetector *ifly_faceDetector;
@property (nonatomic, strong) NSArray *faceInfos;    // 人脸信息
@property (nonatomic, strong) CanvasView *viewCanvas;

@property (nonatomic, assign) BOOL isVideoRecording;
@property (nonatomic, strong) NSString *originalFilePath;
@property (nonatomic, strong) NSMutableArray<SceneModle *>* dataSource;
@property (nonatomic, strong) UIView *elementView;
@property (nonatomic, strong) UIView *elementFixedContainerView;

@property (nonatomic, strong) YFGIFImageView* headImageView;
@property (nonatomic, strong) YFGIFImageView* eyeImageView;
@property (nonatomic, strong) YFGIFImageView* noseImageView;
@property (nonatomic, strong) YFGIFImageView* mouthImageView;
@property (nonatomic, strong) KeMVFaceSticker* mouth_sticker;

@end

@implementation ShowTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setup];
    [self config];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark config camare
/*
 * @brief 初始化摄像头设备
 */
- (void)config{
    //人脸识别参数设置
    _ifly_faceDetector = [IFlyFaceDetector sharedInstance];
    [_ifly_faceDetector setParameter:@"1" forKey:@"detect"];
    [_ifly_faceDetector setParameter:@"1" forKey:@"align"];
    
    //默认是前置摄像头
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.delegate = self;
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, TOP_COVER_HEIGHT, MS_WIDTH, MS_HEIGHT - BOTTOM_COVER_HEIGHT - TOP_COVER_HEIGHT)];
    
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];

    self.viewCanvas = [[CanvasView alloc] initWithFrame:CGRectMake(0, TOP_COVER_HEIGHT, MS_WIDTH, MS_HEIGHT - BOTTOM_COVER_HEIGHT - TOP_COVER_HEIGHT)];
    self.viewCanvas.backgroundColor = [UIColor clearColor];
    NSString *str = [NSString stringWithFormat:@"{{%f, %f}, {220, 240}}",(MS_WIDTH-220)/2,(MS_WIDTH-240)/2+15];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:str forKey:@"RECT_KEY"];
    [dic setObject:@"1" forKey:@"RECT_ORI"];
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    [arr addObject:dic];
    self.viewCanvas.arrFixed = arr;
    self.viewCanvas.hidden = NO;
    [self.filterView addSubview:self.viewCanvas];
    
    _elementView = [[UIView alloc] initWithFrame:CGRectMake(0, TOP_COVER_HEIGHT, MS_WIDTH, MS_HEIGHT - BOTTOM_COVER_HEIGHT - TOP_COVER_HEIGHT)];
    _elementFixedContainerView = [[UIView alloc] initWithFrame:_elementView.bounds];
    [_elementView addSubview:_elementFixedContainerView];
    [self.filterView addSubview:_elementView];
    
    [self.videoCamera removeAllTargets];
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    
    [self loadScene];
}

/*
 * @brief UI 构建
 **/
- (void)setup{
    _topCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MS_WIDTH, TOP_COVER_HEIGHT)];
    [_topCoverView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_topCoverView];
    
    _buttomCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MS_WIDTH, BOTTOM_COVER_HEIGHT)];
    [_buttomCoverView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_buttomCoverView];
    
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn setFrame:CGRectMake(0, 0, 60, 60)];
    [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeBtn setBackgroundColor:[UIColor redColor]];
    [_closeBtn addTarget:self action:@selector(closeShowTimeView) forControlEvents:UIControlEventTouchUpInside];
    [_topCoverView addSubview:_closeBtn];
    
    _stopRecord = [UIButton buttonWithType:UIButtonTypeCustom];
    [_stopRecord setFrame:CGRectMake(0, 0, 60, 60)];
    [_stopRecord setTitle:@"结束" forState:UIControlStateNormal];
    [_stopRecord setBackgroundColor:[UIColor redColor]];
    [_stopRecord addTarget:self action:@selector(stopVideoRecord) forControlEvents:UIControlEventTouchUpInside];
    [_buttomCoverView addSubview:_stopRecord];
    
    _switchCamare = [UIButton buttonWithType:UIButtonTypeCustom];
    [_switchCamare setFrame:CGRectMake(0, 0, 60, 60)];
    [_switchCamare setTitle:@"切换" forState:UIControlStateNormal];
    [_switchCamare setBackgroundColor:[UIColor redColor]];
    [_switchCamare addTarget:self action:@selector(switchTheCamare) forControlEvents:UIControlEventTouchUpInside];
    [_buttomCoverView addSubview:_switchCamare];
    
    _shotBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shotBtn setFrame:CGRectMake(0, 0, 60, 60)];
    [_shotBtn setTitle:@"拍摄" forState:UIControlStateNormal];
    [_shotBtn setBackgroundColor:[UIColor redColor]];
    [_shotBtn addTarget:self action:@selector(clickPhotoBtn) forControlEvents:UIControlEventTouchUpInside];
    [_buttomCoverView addSubview:_shotBtn];
    
    __weak typeof (self) weakSelf = self;
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.topCoverView).offset(-40);
        make.top.equalTo(weakSelf.topCoverView).offset(10);
        make.height.equalTo(@60);
        make.width.equalTo(@60);
    }];

    [_switchCamare mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-40);
        make.centerY.equalTo(weakSelf.buttomCoverView);
        make.height.equalTo(@60);
        make.width.equalTo(@60);
    }];
    
    [_topCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(MS_WIDTH, TOP_COVER_HEIGHT));
    }];
    
    [_buttomCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(MS_WIDTH, BOTTOM_COVER_HEIGHT));
    }];
    
    [_shotBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.buttomCoverView);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [_stopRecord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.buttomCoverView);
        make.left.equalTo(@40);
        make.height.equalTo(@60);
        make.width.equalTo(@60);
    }];
    
//    [_photoPreviewView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(weakSelf.buttomCoverView);
//        make.left.equalTo(@40);
//        make.height.equalTo(@80);
//        make.width.equalTo(@80);
//    }];
}

/*
 * @brief 关闭直播界面
 */
- (void)closeShowTimeView{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
 *@brief 拍照
 */
- (void)clickPhotoBtn{
//    _pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
//    unlink([_pathToMovie UTF8String]);
//    NSURL *movieURL = [NSURL fileURLWithPath:_pathToMovie];
//    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(360.0, 640.0)];
//    _movieWriter.encodingLiveVideo = YES;
//    _movieWriter.shouldPassthroughAudio = YES;
//    [_filter addTarget:_movieWriter];
//    _videoCamera.audioEncodingTarget = _movieWriter;
//    [_movieWriter startRecording];
}

/*
 *@brief 切换摄像头
 */
- (void)switchTheCamare{
    [_videoCamera rotateCamera];
}

#pragma mark - add sense (添加场景)
- (void)showSenseView:(SceneModle*)scene{
    NSString* dest_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent.stringByDeletingPathExtension];
    
    NSString* jsonString = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/info.json", dest_path] encoding:NSUTF8StringEncoding error:nil];
    
    NSError* err;
    NSDictionary* json_dict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:&err];
    
    if (err) {
        return;
    }
    
    NSArray* stickers = [json_dict objectForKey:@"fixed_stickers"];
    
    NSArray* face_stickers = [json_dict objectForKey:@"face_stickers"];
    for (NSDictionary* dict in face_stickers) {
        KeMVFaceSticker* sticker = [KeMVFaceSticker kk_modelWithDict:dict];
        
        YFGIFImageView* faceView = [[YFGIFImageView alloc] initWithFrame:CGRectMake(0, 0, sticker.width, sticker.height)];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:sticker.frame_count];
        NSString* img_path_format = [NSString stringWithFormat:@"%@/%@/%@.png", dest_path, sticker.sticker_directory, sticker.filename_format];
        for (NSInteger i = 1; i < sticker.frame_count + 1; i++) {
            NSString* img_path = [NSString stringWithFormat:img_path_format, i];
            [arr addObject:[[UIImage alloc] initWithContentsOfFile:img_path]];
        }
        faceView.gifImages = arr;
        faceView.gifImagesTime = sticker.animation_duration / sticker.frame_count;
        //faceView.backgroundColor = RYBRGBA(arc4random() % 250, arc4random() % 250, arc4random() % 250, 0.2);
        faceView.contentMode = UIViewContentModeScaleAspectFit;
        [_elementFixedContainerView addSubview:faceView];
        if (sticker.faceType == MVStickerFaceTypeEye) {
            self.eyeImageView = faceView;
        } else if (sticker.faceType == MVStickerFaceTypeHead) {
            self.headImageView = faceView;
        } else if (sticker.faceType == MVStickerFaceTypeNose) {
            self.noseImageView = faceView;
        } else if (sticker.faceType == MVStickerFaceTypeMouth) {
            self.mouthImageView = faceView;
            self.mouth_sticker = sticker;
        }
    }
    
//    for (NSDictionary* dict in stickers) {
//
//        KeMVSticker* sticker = [KeMVSticker kk_modelWithDict:dict];
//        float scale = 480.0 / 540;
//        float display_width = sticker.width * scale;
//        float display_height = sticker.height * scale;
//        if (sticker.display_width > 0 && sticker.display_height == 0) {
//            display_width = sticker.display_width * sceneRecordWidth;
//            display_height = sticker.height / sticker.width * display_width;
//        }
//        if (sticker.display_height > 0 && sticker.display_width == 0) {
//            display_height = sticker.display_height * sceneRecordHeight;
//            display_width = sticker.width / sticker.height * display_height;
//        }
//        if (sticker.display_height > 0 && sticker.display_width > 0) {
//            display_height = sticker.display_height * sceneRecordHeight;
//            display_width = sticker.display_width * sceneRecordWidth;
//        }
//        sticker.display_width = display_width;
//        sticker.display_height = display_height;
//        sticker.positionX = sceneRecordWidth * sticker.positionX - sticker.anchorpointX * sticker.display_width;
//        sticker.positionY = sceneRecordHeight * sticker.positionY - sticker.anchorpointY * sticker.display_height;
//
//        YFGIFImageView* gifView = [[YFGIFImageView alloc] initWithFrame:CGRectMake(sticker.positionX, sticker.positionY, sticker.display_width, sticker.display_height)];
//        gifView.contentMode = UIViewContentModeScaleAspectFit;
//        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:sticker.frame_count];
//        NSString* img_path_format = [NSString stringWithFormat:@"%@/%@/%@.png", dest_path, sticker.sticker_directory, sticker.filename_format];
//        for (int i = 1; i < sticker.frame_count + 1; i++) {
//            NSString* img_path = [NSString stringWithFormat:img_path_format, i];
//            [arr addObject:[[UIImage alloc] initWithContentsOfFile:img_path]];
//        }
//        gifView.gifImages = arr;
//        gifView.gifImagesTime = sticker.animation_duration / sticker.frame_count;
//        [gifView startGIFWithRunLoopMode:NSRunLoopCommonModes
//                         andImageDidLoad:^(CGSize imageSize){
//                         }];
//        [_elementFixedContainerView addSubview:gifView];
//    }
    
}

- (void)loadScene{
    //local
//    SceneModle* mv_scene = [[SceneModle alloc] init];
//    NSString* zip_path = [[NSBundle mainBundle] pathForResource:@"mv_scene/forest_music.zip" ofType:nil];
//    mv_scene.zip_path_ios = zip_path;
//    [_dataSource addObject:mv_scene];
    
    SceneModle* mv_scene2 = [[SceneModle alloc] init];
    NSString* zip_path2 = [[NSBundle mainBundle] pathForResource:@"garden.zip" ofType:nil];
    mv_scene2.zip_path_ios = zip_path2;
    [_dataSource addObject:mv_scene2];
    
    [self unzipScene:mv_scene2];
}

- (void)unzipScene:(SceneModle*)scene{
//    NSString* scene_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene.zip_path_ios.lastPathComponent];
    NSString *scene_path = scene.zip_path_ios;
    NSString* dest_path = [NSString stringWithFormat:@"%@/%@", CachePathForMV, scene_path.lastPathComponent.stringByDeletingPathExtension];
    NSString* info_path = [NSString stringWithFormat:@"%@/info.json", dest_path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:info_path]) {
        [self showSenseView:scene];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SSZipArchive unzipFileAtPath:scene_path
                        toDestination:dest_path
                      progressHandler:^(NSString* _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
                      }
                    completionHandler:^(NSString* _Nonnull path, BOOL succeeded, NSError* _Nullable error) {
                        if (succeeded) {
                            [self showSenseView:scene];
                        } else {
                            NSLog(@"%@ 加载出错", error);
                        }
                    }];
    });
    
}

- (void)reSetFaceUI{
    if (self.faceInfos.count < 1) {
        //self.eyeImageView.hidden = YES;
        self.eyeImageView.transform = CGAffineTransformIdentity;
        [self.eyeImageView stopGIF];
        self.eyeImageView.hidden = YES;
        self.headImageView.transform = CGAffineTransformIdentity;
        [self.headImageView stopGIF];
        self.headImageView.hidden = YES;
        self.noseImageView.transform = CGAffineTransformIdentity;
        [self.noseImageView stopGIF];
        self.noseImageView.hidden = YES;
        self.mouthImageView.transform = CGAffineTransformIdentity;
        [self.mouthImageView stopGIF];
        self.mouthImageView.hidden = YES;
        return;
    }
    
    //鼻子 绿
    NSDictionary* facedict = [self.faceInfos objectAtIndex:0];
    //                NSString *faceRectStr = [facedict objectForKey:RECT_KEY];
    NSDictionary* facePointDict = [facedict objectForKey:POINTS_KEY];
    
    CGFloat rotate = [self rotateFromDict:facePointDict];
    
    //头部 红
    CGPoint eyebow_left_point = CGPointFromString(facePointDict[@"left_eyebrow_left_corner"]);
    CGPoint eyebow_right_point = CGPointFromString(facePointDict[@"right_eyebrow_right_corner"]);
    CGFloat eyebow_width = sqrt(pow((eyebow_left_point.x - eyebow_right_point.x), 2) + pow((eyebow_left_point.y - eyebow_right_point.y), 2));
    eyebow_width = eyebow_width * 2;
    CGFloat eyebow_middle_y = (eyebow_left_point.y + eyebow_right_point.y) / 2;
    CGFloat eyebow_middle_x = (eyebow_left_point.x + eyebow_right_point.x) / 2;
    CGFloat head_height = eyebow_width * 0.7;
    
    CGRect head_rect = CGRectMake(eyebow_middle_x - eyebow_width / 2, eyebow_middle_y - head_height, eyebow_width, head_height);
    self.headImageView.frame = head_rect;
    [self.headImageView startGIF];
    self.headImageView.hidden = NO;
    self.headImageView.transform = CGAffineTransformMakeRotation(rotate);
    
    CGPoint nose_left = CGPointFromString(facePointDict[@"nose_left"]);
    CGPoint nose_right = CGPointFromString(facePointDict[@"nose_right"]);
    CGPoint nose_top = CGPointFromString(facePointDict[@"nose_top"]);
    CGPoint nose_bottom = CGPointFromString(facePointDict[@"nose_bottom"]);
    CGFloat nose_width = sqrt(pow((nose_left.x - nose_right.x), 2) + pow((nose_left.y - nose_right.y), 2));
    CGFloat nose_height = sqrt(pow((nose_top.x - nose_bottom.x), 2) + pow((nose_top.y - nose_bottom.y), 2));
    CGFloat nose_middle_x = (nose_left.x + nose_right.x) / 2;
    CGFloat nose_middle_y = (nose_top.y + nose_bottom.y) / 2;
    CGRect nose_rect = CGRectMake(nose_middle_x - eyebow_width / 2, nose_middle_y - nose_height * 0.5, eyebow_width, nose_height);
    [self.noseImageView setFrame:nose_rect];
    self.noseImageView.transform = CGAffineTransformMakeRotation(rotate);
    //                imageView.frame = [(NSValue *)weakSelf.faceBoundArr[idx] CGRectValue] ;
    self.noseImageView.hidden = NO;
    [self.noseImageView startGIF];
    
    //眼睛 蓝
    CGPoint eye_left_point = CGPointFromString(facePointDict[@"left_eye_left_corner"]);
    CGPoint eye_right_point = CGPointFromString(facePointDict[@"right_eye_right_corner"]);
    CGFloat eye_width = sqrt(pow((eye_left_point.x - eye_right_point.x), 2) + pow((eye_left_point.y - eye_right_point.y), 2));
    eye_width = eye_width * 1.5;
    CGFloat eye_middle_y = (eye_left_point.y + eye_right_point.y) / 2;
    CGFloat eye_middle_x = (eye_left_point.x + eye_right_point.x) / 2;
    CGFloat eye_height = 100;
    CGRect eye_rect = CGRectMake(eye_middle_x - eye_width / 2, eye_middle_y - eye_height / 2, eye_width, eye_height);
    self.eyeImageView.frame = eye_rect;
    [self.eyeImageView startGIF];
    self.eyeImageView.hidden = NO;
    self.eyeImageView.transform = CGAffineTransformMakeRotation(rotate);
    
    //嘴巴
    
    CGPoint mouth_left_corner = CGPointFromString(facePointDict[@"mouth_left_corner"]);
    CGPoint mouth_right_corner = CGPointFromString(facePointDict[@"mouth_right_corner"]);
    CGPoint mouth_middle = CGPointFromString(facePointDict[@"mouth_lower_lip_bottom"]);
    CGFloat mouth_width = sqrt(pow((mouth_left_corner.x - mouth_right_corner.x), 2) + pow((mouth_left_corner.y - mouth_right_corner.y), 2));
    mouth_width = mouth_width * 2;
    CGFloat mouth_height = mouth_width / self.mouth_sticker.width * self.mouth_sticker.height;
    [self.mouthImageView startGIF];
    self.mouthImageView.hidden = NO;
    CGRect mouth_rect = CGRectMake(mouth_middle.x - self.mouth_sticker.anchorpointX * mouth_width, mouth_middle.y - self.mouth_sticker.anchorpointY * mouth_height, mouth_width, mouth_height);
    self.mouthImageView.frame = mouth_rect;
    self.mouthImageView.transform = CGAffineTransformMakeRotation(rotate);
}

- (void)hideFace
{
    self.faceInfos = nil;
    //self.eyeImageView.hidden = YES;
    [self reSetFaceUI];
}

- (CGFloat)rotateFromDict:(NSDictionary*)facePointDict
{
    CGPoint left_eye_left_corner = CGPointFromString(facePointDict[@"left_eye_left_corner"]);
    CGPoint right_eye_right_corner = CGPointFromString(facePointDict[@"right_eye_right_corner"]);
    //    CGPoint nose_top = CGPointFromString(facePointDict[@"nose_top"]);
    //    CGPoint eyeCenter = CGPointMake((left_eye_left_corner.x + right_eye_right_corner.x) / 2., (left_eye_left_corner.y + right_eye_right_corner.y) / 2.);
    CGPoint point0 = left_eye_left_corner;
    CGPoint point1 = right_eye_right_corner;
    CGFloat rotate = 0;
    if (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront) {
        rotate = atan2(point0.y - point1.y, point0.x - point1.x);
        
    } else {
        rotate = atan2(point1.y - point0.y, point1.x - point0.x);
    }
    return rotate;
}

#pragma mark - Record Controller （录制控制方法）
/*
 * @brief 开始录制
 */
- (void)beginRecord{
    
}

/*
 * @brief 暂停
 */
- (void)pauseRecord{
    
}

/*
 * @brief 停止录制
 */
- (void)endRecord{
    
}

/*
 * @brief 准备录制
 */
- (void)prepareRecord{
    NSArray* arr = @[ @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9" ];
    NSString* timeString = [NSString stringWithFormat:@"mv_%0.f", [[NSDate date] timeIntervalSince1970]];
    NSMutableString* randomStr = [NSMutableString stringWithString:timeString];
    for (int i = 0; i < 3; i++) {
        [randomStr appendString:arr[arc4random() % 10]];
    }
    NSString* path = [NSString stringWithFormat:@"%@/%@.mp4", CacheRecordPathForMV, randomStr];
    self.originalFilePath = path;
}

/*
 * @brief 结束录制
 */
- (void)stopVideoRecord{
    [_filter removeTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = nil;
    [_movieWriter finishRecording];
    [self saveVideoToAlbum:_pathToMovie];
}

/*
 * @brief 保存至相册
 */
- (void)saveVideoToAlbum:(NSString *)url{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_pathToMovie))
    {
        NSURL *movieURL = [NSURL fileURLWithPath:_pathToMovie];
        [library writeVideoAtPathToSavedPhotosAlbum:movieURL completionBlock:^(NSURL *assetURL, NSError *error)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (error) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存失败" message:nil
                                                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 } else {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频保存成功" message:nil
                                                                    delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [alert show];
                 }
             });
         }];
    }
}

- (IFlyFaceDirectionType)faceImageOrientation
{
    
    IFlyFaceDirectionType faceOrientation = IFlyFaceDirectionTypeLeft;
    BOOL isFrontCamera = (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront);
    switch (self.interfaceOrientation) {
        case UIDeviceOrientationPortrait: { //
            faceOrientation = IFlyFaceDirectionTypeLeft;
        } break;
        case UIDeviceOrientationPortraitUpsideDown: {
            faceOrientation = IFlyFaceDirectionTypeRight;
        } break;
        case UIDeviceOrientationLandscapeRight: {
            faceOrientation = isFrontCamera ? IFlyFaceDirectionTypeUp : IFlyFaceDirectionTypeDown;
        } break;
        default: { //
            faceOrientation = isFrontCamera ? IFlyFaceDirectionTypeDown : IFlyFaceDirectionTypeUp;
        }
            
            break;
    }
    
    return faceOrientation;
}

- (IFlyFaceImage *)faceImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t* lumaBuffer = (uint8_t*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, 0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    IFlyFaceDirectionType faceOrientation = [self faceImageOrientation];
    
    IFlyFaceImage* faceImage = [[IFlyFaceImage alloc] init];
    if (!faceImage) {
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    
    faceImage.data = (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width = width;
    faceImage.height = height;
    faceImage.direction = faceOrientation;
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    return faceImage;
}

#pragma mark - GPUImageVideoCameraDelegate
//Face Detection
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    //人脸识别
    IFlyFaceImage *iflyFace = [self faceImageFromSampleBuffer:sampleBuffer];
    [self onOutputFaceImage:iflyFace];
    iflyFace = nil;
}

- (void)onOutputFaceImage:(IFlyFaceImage*)img{
    NSString *strResult = [_ifly_faceDetector trackFrame:img.data withWidth:img.width height:img.height direction:img.direction];    
    img.data = nil;
    
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(praseTrackResult:OrignImage:)];
    if (!sig) return;
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:self];
    [invocation setSelector:@selector(praseTrackResult:OrignImage:)];
    [invocation setArgument:&strResult atIndex:2];
    [invocation setArgument:&img atIndex:3];
    [invocation retainArguments];
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil  waitUntilDone:NO];
    img = nil;
    
}

#pragma mark - 开启识别 关闭识别
//- (void)showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons{
//    if (self.viewCanvas.hidden) {
//        self.viewCanvas.hidden = NO;
//    }
//    self.viewCanvas.arrPersons = arrPersons;
//    [self.viewCanvas setNeedsDisplay] ;
//}
//
//- (void)hideFace{
//    if (!self.viewCanvas.hidden) {
//        self.viewCanvas.hidden = YES ;
//    }
//}

#pragma mark - 脸部识别框 脸部识别部位
- (NSString *)praseDetect:(NSDictionary *)positionDic OrignImage:(IFlyFaceImage *)faceImg{
    
    if(!positionDic){
        return nil;
    }
    
    BOOL isFrontCamera = _videoCamera.frontFacingCameraPresent;
    
    CGFloat width = self.view.frame.size.width;
    CGFloat widthScaleBy = width / faceImg.height;
    CGFloat heightScaleBy = width / 0.75 / faceImg.width;
    
    CGFloat bottom =[[positionDic objectForKey:KCIFlyFaceResultBottom] floatValue];
    CGFloat top=[[positionDic objectForKey:KCIFlyFaceResultTop] floatValue];
    CGFloat left=[[positionDic objectForKey:KCIFlyFaceResultLeft] floatValue];
    CGFloat right=[[positionDic objectForKey:KCIFlyFaceResultRight] floatValue];
    
    float cx = (left + right) / 2;
    float cy = (top + bottom) / 2;
    float w = right - left;
    float h = bottom - top;
    
    float ncx = cy;
    float ncy = cx;
    
    CGRect rectFace = CGRectMake(ncx - w / 2, ncy - w / 2, w, h);
    
    if (!isFrontCamera) {
        rectFace = rSwap(rectFace);
        rectFace = rRotate90(rectFace, faceImg.height, faceImg.width);
    }
    
    rectFace = rScale(rectFace, widthScaleBy, heightScaleBy);
    
    return NSStringFromCGRect(rectFace);
}

-(NSMutableDictionary*)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg{
    
    if (!landmarkDic) {
        return nil;
    }
    
    // 判断摄像头方向
    BOOL isFrontCamera = (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront);
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat width = self.view.frame.size.width;
    CGFloat widthScaleBy = width / faceImg.height;
    CGFloat heightScaleBy = width / 0.75 / faceImg.width;
    
    NSMutableDictionary *arrStrPoints = [NSMutableDictionary dictionary];
    NSEnumerator* keys = [landmarkDic keyEnumerator];
    for (id key in keys) {
        id attr = [landmarkDic objectForKey:key];
        if (attr && [attr isKindOfClass:[NSDictionary class]]) {
            
            id attr = [landmarkDic objectForKey:key];
            CGFloat x = [[attr objectForKey:KCIFlyFaceResultPointX] floatValue];
            CGFloat y = [[attr objectForKey:KCIFlyFaceResultPointY] floatValue];
            
            CGPoint p = CGPointMake(y, x);
            
            if (!isFrontCamera) {
                p = pSwap(p);
                p = pRotate90(p, faceImg.height, faceImg.width);
            }
            
            p = pScale(p, widthScaleBy, heightScaleBy);
            
            //            NSDictionary *dict = @{key : NSStringFromCGPoint(p)};
            //            [arrStrPoints addObject:dict];
//            [arrStrPoints setObject:NSStringFromCGPoint(p) forKey:key];
            //            dict = nil;
            [arrStrPoints setObject:NSStringFromCGPoint(p) forKey:key];
        }
    }
    return arrStrPoints;
}

#pragma mark - 人脸识别
- (void)praseTrackResult:(NSString *)result OrignImage:(IFlyFaceImage *)faceImg{
    if(!result){
        return;
    }
    
    @try {
        NSError* error;
        NSData* resultData=[result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* faceDic=[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
        resultData=nil;
        if(!faceDic){
            return;
        }
        
        NSString* faceRet=[faceDic objectForKey:KCIFlyFaceResultRet];
        NSArray* faceArray=[faceDic objectForKey:KCIFlyFaceResultFace];
        faceDic=nil;
        
        int ret=0;
        if(faceRet){
            ret=[faceRet intValue];
        }
        //没有检测到人脸或发生错误
        if (ret || !faceArray || [faceArray count]<1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideFace];
            }) ;
            return;
        }
        
        //检测到人脸
        NSMutableArray *arrPersons = [NSMutableArray array] ;
        
        for(id faceInArr in faceArray){
            
            if(faceInArr && [faceInArr isKindOfClass:[NSDictionary class]]){
                
                NSDictionary* positionDic=[faceInArr objectForKey:KCIFlyFaceResultPosition];
                NSString* rectString=[self praseDetect:positionDic OrignImage: faceImg];
                positionDic=nil;
                
                NSDictionary* landmarkDic=[faceInArr objectForKey:KCIFlyFaceResultLandmark];
                NSMutableDictionary* strPoints=[self praseAlign:landmarkDic OrignImage:faceImg];
                landmarkDic=nil;
                
                
                NSMutableDictionary *dicPerson = [NSMutableDictionary dictionary] ;
                if(rectString){
                    [dicPerson setObject:rectString forKey:RECT_KEY];
                }
                if(strPoints){
                    [dicPerson setObject:strPoints forKey:POINTS_KEY];
                }
                
                strPoints=nil;
                
                [dicPerson setObject:@"0" forKey:RECT_ORI];
                [arrPersons addObject:dicPerson] ;
                
                dicPerson=nil;
                
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
                    self.faceInfos = arrPersons;
                    [self reSetFaceUI];
                });
            }
        }
        faceArray=nil;
    }
    @catch (NSException *exception) {
        NSLog(@"prase exception:%@",exception.name);
    }
    @finally {
    }
}

@end

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

#define MS_WIDTH [UIScreen mainScreen].bounds.size.width
#define MS_HEIGHT [UIScreen mainScreen].bounds.size.height
#define TOP_COVER_HEIGHT 60
#define BOTTOM_COVER_HEIGHT 100

@interface ShowTimeViewController ()<AVCapturePhotoCaptureDelegate>
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIButton *switchCamare;
@property (nonatomic, strong) UIButton *shotBtn;
@property (nonatomic, strong) UIView *buttomCoverView;
@property (nonatomic, strong) UIView *topCoverView;
@property (nonatomic, strong) UIImageView *photoPreviewView;

//捕获设备
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
//输入设备
@property (nonatomic, strong) AVCaptureDeviceInput *input;
//输出图片
@property (nonatomic, strong) AVCapturePhotoOutput *output;
//session
@property (nonatomic, strong) AVCaptureSession *session;
//图像预览层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *filterView;

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
    
    _photoPreviewView = [[UIImageView alloc] init];
    [_photoPreviewView setFrame:CGRectMake(0, 0, 80, 80)];
    [_photoPreviewView setBackgroundColor:[UIColor blackColor]];
    [_buttomCoverView addSubview:_photoPreviewView];
    
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
    
    [_photoPreviewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.buttomCoverView);
        make.left.equalTo(@40);
        make.height.equalTo(@80);
        make.width.equalTo(@80);
    }];
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
//    AVCaptureConnection *connect = [_output connectionWithMediaType:AVMediaTypeVideo];
//    if(!connect){
//        NSLog(@"拍照失败");
//        return;
//    }
//
//    [_output capturePhotoWithSettings:[AVCapturePhotoSettings photoSettings] delegate:self];
}

/*
 *@brief 切换摄像头
 */
- (void)switchTheCamare{
//    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
//    if (cameraCount > 1) {
//        NSError *error;
//        //给摄像头的切换添加翻转动画
//        CATransition *animation = [CATransition animation];
//        animation.duration = .5f;
//        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//        animation.type = @"oglFlip";
//
//        AVCaptureDevice *newCamera = nil;
//        AVCaptureDeviceInput *newInput = nil;
//        //拿到另外一个摄像头位置
//        AVCaptureDevicePosition position = [[_input device] position];
//        if (position == AVCaptureDevicePositionFront){
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
//            animation.subtype = kCATransitionFromLeft;//动画翻转方向
//        }
//        else {
//            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
//            animation.subtype = kCATransitionFromRight;//动画翻转方向
//        }
//        //生成新的输入
//        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
//        [self.previewLayer addAnimation:animation forKey:nil];
//        if (newInput != nil) {
//            [self.session beginConfiguration];
//            [self.session removeInput:self.input];
//            if ([self.session canAddInput:newInput]) {
//                [self.session addInput:newInput];
//                self.input = newInput;
//
//            } else {
//                [self.session addInput:self.input];
//            }
//            [self.session commitConfiguration];
//
//        } else if (error) {
//            NSLog(@"toggle carema failed, error = %@", error);
//        }
//    }
    
    [_videoCamera rotateCamera];
}


#pragma -mark config camare
/*
 * @brief 初始化摄像头设备
*/
- (void)config{
//    //默认是前置摄像头
//    _captureDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
//    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.captureDevice error:nil];
//    self.output = [[AVCapturePhotoOutput alloc] init];
//    self.session = [[AVCaptureSession alloc] init];
//
//    //     拿到的图像的大小可以自行设定
//    //    AVCaptureSessionPreset320x240
//    //    AVCaptureSessionPreset352x288
//    //    AVCaptureSessionPreset640x480
//    //    AVCaptureSessionPreset960x540
//    //    AVCaptureSessionPreset1280x720
//    //    AVCaptureSessionPreset1920x1080
//    //    AVCaptureSessionPreset3840x2160
//    self.session.sessionPreset = AVCaptureSessionPreset640x480;
//
//    //输入输出整合设备
//    if([_session canAddInput:_input]){
//        [_session addInput:_input];
//    }
//
//    if([_session canAddOutput:_output]){
//        [_session addOutput:_output];
//    }
//
//    //生成预览层
//    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
//    _previewLayer.frame = CGRectMake(0, TOP_COVER_HEIGHT, MS_WIDTH, MS_HEIGHT - BOTTOM_COVER_HEIGHT - TOP_COVER_HEIGHT);
//    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.view.layer addSublayer:_previewLayer];
//
//    //设备取景开始
//    [_session startRunning];
    
    
    _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, TOP_COVER_HEIGHT, MS_WIDTH, MS_HEIGHT - BOTTOM_COVER_HEIGHT - TOP_COVER_HEIGHT)];
    
    [self.view addSubview:self.filterView];
    [self.videoCamera addTarget:self.filterView];
    [self.videoCamera startCameraCapture];
    
    [self.videoCamera removeAllTargets];
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
//    NSArray *devices = [AVCaptureDevice AVCaptureDeviceDiscoverySession];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices ){
        if ( device.position == position ){
            return device;
        }
    }

    return nil;
}

//#pragma mark - AVCapturePhotoCaptureDelegate
//-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
//{
//    if (error) {
//        NSLog(@"error : %@", error.localizedDescription);
//    }
//
//    if (photoSampleBuffer) {
////        [AVCapturePhoto]
////        NSData *data = [AVCapturePhoto fileDataRepresentation];
//        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
//        UIImage *image = [UIImage imageWithData:data];
//        [_photoPreviewView setImage:image];
//    }
//}

@end

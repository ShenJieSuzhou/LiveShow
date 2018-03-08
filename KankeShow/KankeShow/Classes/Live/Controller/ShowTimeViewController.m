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
@property (nonatomic, strong) NSArray *faceInfo;    // 人脸信息
@property (nonatomic, strong) CanvasView *viewCanvas;

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
    self.viewCanvas.hidden = NO;
    [self.filterView addSubview:self.viewCanvas];
    
    
    [self.videoCamera removeAllTargets];
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
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
    
//    _photoPreviewView = [[UIImageView alloc] init];
//    [_photoPreviewView setFrame:CGRectMake(0, 0, 80, 80)];
//    [_photoPreviewView setBackgroundColor:[UIColor blackColor]];
//    [_buttomCoverView addSubview:_photoPreviewView];
    
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
    _pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([_pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:_pathToMovie];
    _movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(360.0, 640.0)];
    _movieWriter.encodingLiveVideo = YES;
    _movieWriter.shouldPassthroughAudio = YES;
    [_filter addTarget:_movieWriter];
    _videoCamera.audioEncodingTarget = _movieWriter;
    [_movieWriter startRecording];
}

/*
 *@brief 切换摄像头
 */
- (void)switchTheCamare{
    [_videoCamera rotateCamera];
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

- (IFlyFaceImage*)faceImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
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
    NSLog(@"%@", strResult);
    
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
- (void)showFaceLandmarksAndFaceRectWithPersonsArray:(NSMutableArray *)arrPersons{
    if (self.viewCanvas.hidden) {
        self.viewCanvas.hidden = NO;
    }
    self.viewCanvas.arrPersons = arrPersons;
    [self.viewCanvas setNeedsDisplay] ;
}

- (void)hideFace{
    if (!self.viewCanvas.hidden) {
        self.viewCanvas.hidden = YES ;
    }
}

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

-(NSMutableArray*)praseAlign:(NSDictionary* )landmarkDic OrignImage:(IFlyFaceImage*)faceImg{
    
    if (!landmarkDic) {
        return nil;
    }
    
    // 判断摄像头方向
    BOOL isFrontCamera = (_videoCamera.inputCamera.position == AVCaptureDevicePositionFront);
    
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat width = self.view.frame.size.width;
    CGFloat widthScaleBy = width / faceImg.height;
    CGFloat heightScaleBy = width / 0.75 / faceImg.width;
    
    NSMutableArray *arrStrPoints = [NSMutableArray array];
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
            [arrStrPoints addObject:NSStringFromCGPoint(p)];
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
                NSMutableArray* strPoints=[self praseAlign:landmarkDic OrignImage:faceImg];
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
                    [self showFaceLandmarksAndFaceRectWithPersonsArray:arrPersons];
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

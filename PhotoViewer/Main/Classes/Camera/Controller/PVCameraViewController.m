//
//  PVCameraViewController.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVCameraViewController.h"
#import "PVCameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface PVCameraViewController () <AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, strong) dispatch_queue_t videoQueue;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, weak) AVCaptureDeviceInput *activeVideoInput;
@property (nonatomic, weak) AVCaptureDeviceInput *activeAudioInput;
@property (nonatomic, strong) AVCapturePhotoOutput *imageOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@property (nonatomic, strong) PVCameraPreviewView *previewView;
@property (nonatomic, strong) UISegmentedControl *recordingModeSelect;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int timeSec;
@property (nonatomic) int timeMin;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, strong) NSURL *outputURL;

@end

@implementation PVCameraViewController

#pragma mark - Lazy Loading
- (PVCameraPreviewView *)previewView
{
    if (!_previewView)
    {
        _previewView = [[PVCameraPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _previewView;
}

#pragma mark - View Controller Life Circle
- (void)viewDidLoad
{
    [super viewDidLoad];
    _isRecording = NO;
    NSError *error;
    
    // Setup the seesion
    if ([self setupPhotoSession:&error])
    {
        [(AVCaptureVideoPreviewLayer *)self.previewView.layer setSession:_captureSession];
        [self startSession:_captureSession];
    }

    self.view.backgroundColor = [UIColor blackColor];
    
    // Add button
    UIButton *takePhotoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 150, 60, 60)];
    takePhotoButton.backgroundColor = [UIColor redColor];
    
    // 设置圆角
    takePhotoButton.layer.cornerRadius = 30;
    takePhotoButton.layer.masksToBounds = YES;
    CGPoint center = takePhotoButton.center;
    center.x = [UIScreen mainScreen].bounds.size.width / 2;
    takePhotoButton.center = center;
    [takePhotoButton addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_previewView];
    [self.view addSubview:takePhotoButton];
    
    // Add recording button background
    _circleLayer = [[CAShapeLayer alloc] init];
    _circleLayer.lineWidth = 3;
    _circleLayer.strokeColor = [UIColor redColor].CGColor;
    _circleLayer.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:takePhotoButton.center radius:35 startAngle:(0*M_PI) endAngle:(2*M_PI) clockwise:NO];
    _circleLayer.path = [circlePath CGPath];
    [self.view.layer addSublayer:_circleLayer];
    _circleLayer.hidden = YES;
    
    // Add UISegmented Control
    NSArray *recordingModeArray = @[@"拍照", @"录像"];
    _recordingModeSelect = [[UISegmentedControl alloc] initWithItems:recordingModeArray];
    [_recordingModeSelect setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 50, 100, 100, 30)];
    _recordingModeSelect.selectedSegmentIndex = 0;
    [self.view addSubview:_recordingModeSelect];
    
    // Add TimeLabel
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 100, 30)];
    [self.view addSubview:_timeLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _timeLabel.hidden = YES;
    [self startSession:_captureSession];
}

#pragma mark - Setting Capture Session
- (BOOL)setupPhotoSession:(NSError **)error
{
    // Init the capture session
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    self.captureSession = session;
    
    // 设置图像分辨率
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    // Get the device and input
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:error];
    
    // Add input into session
    if (videoInput)
    {
        if ([self.captureSession canAddInput:videoInput])
        {
            [self.captureSession addInput:videoInput];
            self.activeVideoInput = videoInput;
        }
    }
    else
    {
        return NO;
    }
    
    // Add audio device
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:error];
    if ([_captureSession canAddInput:audioInput])
    {
        [_captureSession addInput:audioInput];
        _activeAudioInput = audioInput;
    }
    else
    {
        return NO;
    }
    
    
    // Add movie output
    _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([_captureSession canAddOutput:_movieOutput])
    {
        [_captureSession addOutput:_movieOutput];
    }
    // Add output into session
    _imageOutput = [[AVCapturePhotoOutput alloc] init];
    if ([self.captureSession canAddOutput:_imageOutput])
    {
        [self.captureSession addOutput:_imageOutput];
    }
    
    if (!_videoQueue)
    {
        // Create new queue for photo
        _videoQueue = dispatch_queue_create("photo.Queue", NULL);
    }
    return YES;
}

- (void)startSession:(AVCaptureSession *)session
{
    if (![session isRunning])
    {
        dispatch_async(_videoQueue, ^{
            [session startRunning];
        });
    }
}

- (void)stopSession:(AVCaptureSession *)session
{
    if ([session isRunning])
    {
        dispatch_async(_videoQueue, ^{
            [session stopRunning];
        });
    }
}

#pragma mark - Action
// UIButton Click Action
- (void)buttonClick
{
    /* Select action by UISegmentedControl, mode == 0 is photo mode, mode == 1 is video mode
    */
    NSInteger mode = _recordingModeSelect.selectedSegmentIndex;
    if (mode == 0)
    {
        [self takePhoto];
    }
    else
    {
        if (_isRecording)
        {
            // Stop recording and set the timer pause
            [_timer setFireDate:[NSDate distantFuture]];
            [_movieOutput stopRecording];
            _timeLabel.hidden = YES;
            _circleLayer.hidden = YES;
            _isRecording = !_isRecording;
            self.recordingModeSelect.enabled = YES;
        }
        else
        {
            // Start recording
            [self startRecording];
            self.recordingModeSelect.enabled = NO;
            _circleLayer.hidden = NO;
        }
    }
}

// Timer Pass Action
- (void)timePass:(NSTimer *)timer
{
    _timeSec ++;
    if (_timeSec == 60)
    {
        _timeSec = 0;
        _timeMin ++;
    }
    NSString *timeNow = [NSString stringWithFormat:@"%02d:%02d", _timeMin, _timeSec];
    _timeLabel.text = timeNow;
}


#pragma mark - Take Photo
- (void)takePhoto
{
    AVCaptureConnection *connection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (connection.isVideoOrientationSupported)
    {
        connection.videoOrientation = [self currentVideoOrientation];
    }
    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    [self.imageOutput capturePhotoWithSettings:[AVCapturePhotoSettings photoSettingsWithFormat:setDic] delegate:self];
}

- (AVCaptureVideoOrientation)currentVideoOrientation
{
    AVCaptureVideoOrientation orientation;
    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
    }
    return orientation;
}

#pragma mark - Save Photo
- (UIAlertController *)createAlertView:(NSString *)string
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
    [alertController addAction:action];
    return alertController;
}

- (void)getAlbumAuthorization:(UIImage *)image
{
    AVAuthorizationStatus cameraStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (cameraStatus == AVAuthorizationStatusAuthorized)
    {
        switch (status) {
            case PHAuthorizationStatusNotDetermined:
            {
                __weak typeof(self) wself = self;
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (status == PHAuthorizationStatusAuthorized)
                        {
                            __strong typeof(wself) self = wself;
                            [self savePhoto:image];
                        }
                        else
                        {
                            __strong typeof(wself) self = wself;
                            UIAlertController *alertController = [self createAlertView:@"请到设置打开本APP的相册使用权限"];
                            [self presentViewController:alertController animated:YES completion:nil];
                        }
                    });
                }];
                break;
            }
            case PHAuthorizationStatusAuthorized:{
                [self savePhoto:image];
                break;
            }
            default:{
                UIAlertController *alertController = [self createAlertView:@"请到设置打开本APP的相册使用权限"];
                [self presentViewController:alertController animated:YES completion:nil];
                break;
            }
        }
    }
    else
    {
        UIAlertController *alertController = [self createAlertView:@"请到设置打开本APP的相机使用权限"];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)savePhoto:(UIImage *)image
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {}];
}

#pragma mark - Recording
- (void)startRecording
{
    AVCaptureConnection *videoConnection = [_movieOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection.isVideoOrientationSupported)
    {
        videoConnection.videoOrientation = [self currentVideoOrientation];
    }
    
    // 相机稳定性设置
    if ([videoConnection isVideoStabilizationSupported])
    {
        videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeCinematic;
    }
    
    AVCaptureDevice *device = _activeVideoInput.device;
    // 摄像头平滑对焦模式
    if ([device isSmoothAutoFocusEnabled])
    {
        NSError *error;
        if ([device lockForConfiguration:&error])
        {
            device.smoothAutoFocusEnabled = YES;
            [device unlockForConfiguration];
        }
    }
    
    // Get unique URL for movie
    _outputURL = [self getMovieURL];
    
    // Check authorization
    AVAuthorizationStatus videoStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoStatus != AVAuthorizationStatusAuthorized || audioStatus != AVAuthorizationStatusAuthorized)
    {
        UIAlertController *alertController = [self createAlertView:@"请到设置打开本APP的相机和麦克风使用权限"];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        // Start recording
        [self.movieOutput startRecordingToOutputFileURL:_outputURL recordingDelegate:self];
        
        // Set time label
        self.timeSec = 0;
        self.timeMin = 0;
        
        NSString *timeNow = [NSString stringWithFormat:@"%02d:%02d", _timeMin, _timeSec];
        _timeLabel.hidden = NO;
        _timeLabel.text = timeNow;
        
        if (!_timer)
        {
            // Init timer and run
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timePass:) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        }
        else
        {
            // Run timer
            [_timer setFireDate:[NSDate distantPast]];
        }
        _isRecording = !_isRecording;
    }
}

- (NSURL *)getMovieURL
{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"LDMovie" stringByAppendingPathExtension:@"mov"]];
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - AVCapturePhotoCaptureDelegate
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(nullable NSError *)error
{
    NSData *data = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData:data];
    
    [self getAlbumAuthorization:image];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    if (!error)
    {
        __weak typeof (self) wself = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    // Save the movie file to the photo library
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        PHAssetResourceCreationOptions* options = [[PHAssetResourceCreationOptions alloc] init];
                        options.shouldMoveFile = YES;
                        PHAssetCreationRequest* creationRequest = [PHAssetCreationRequest creationRequestForAsset];
                        [creationRequest addResourceWithType:PHAssetResourceTypeVideo fileURL:outputFileURL options:options];
                    } completionHandler:^(BOOL success, NSError* error) {
                        if (!success) {
                            __strong typeof (wself) self = wself;
                            UIAlertController *alertController = [self createAlertView:@"视频保存失败"];
                            [self presentViewController:alertController animated:YES completion:nil];
                        }
                    }];
                }
                else
                {
                    __strong typeof (wself) self = wself;
                    UIAlertController *alertController = [self createAlertView:@"请到设置打开本APP的相册使用权限"];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            });
        }];
    }
    self.outputURL = nil;
}

@end


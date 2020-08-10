//
//  PVCameraPreviewView.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVCameraPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PVCameraPreviewView

+ (Class)layerClass{
    return [AVCaptureVideoPreviewLayer class];
}

@end

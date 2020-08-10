//
//  PVPhotoModel.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVPhotoModel : NSObject

@property (nonatomic, strong) PHAsset *photo;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic) BOOL playing;
@property (nonatomic) BOOL isPause;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong) AVURLAsset *urlAsset;

@end

NS_ASSUME_NONNULL_END

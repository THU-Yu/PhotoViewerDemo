//
//  PVBrowseCollectionViewCell.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVBrowseCollectionViewCell.h"
#import "PVPhotoModel.h"

@implementation PVBrowseCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _playVideoButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width / 2 - 25, self.bounds.size.height / 2 - 25, 50, 50)];
    [self addSubview:_imageView];
    [self addSubview:_playVideoButton];
    _playVideoButton.hidden = YES;
    [_playVideoButton addTarget:self action:@selector(playVideoButtonClick) forControlEvents:UIControlEventTouchDown];
    _playerLayer = [[AVPlayerLayer alloc] init];
    _playerLayer.frame = _imageView.frame;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect ;
    [_imageView.layer insertSublayer:_playerLayer atIndex:0];
    return self;
}

- (void)setPhotoModel:(PVPhotoModel *)photoModel
{
    _photoModel = photoModel;
    if (_photoModel.photo)
    {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.networkAccessAllowed = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        __weak typeof(self) wself = self;
        [[PHImageManager defaultManager] requestImageForAsset:_photoModel.photo targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            __strong typeof(wself) self = wself;
            if (result)
            {
                self.imageView.image = result;
            }
        }];
        if (photoModel.photo.mediaType == PHAssetMediaTypeVideo)
        {
            self.playVideoButton.hidden = NO;
        }
        else
        {
            _playVideoButton.hidden = YES;
        }
    }
}

- (void)playVideoButtonClick
{
    if (!_photoModel.playing)
    {
        if (!self.photoModel.isPause)
        {
            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
            options.networkAccessAllowed = YES;
            __weak typeof (self) wself = self;
            [[PHImageManager defaultManager] requestAVAssetForVideo:_photoModel.photo options:options resultHandler:^(AVAsset *asset, AVAudioMix *audioMix, NSDictionary *info) {
                if ([asset isKindOfClass:[AVURLAsset class]]) {
                    AVURLAsset* videoAsset = (AVURLAsset*)asset;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof (wself) self = wself;
                        self.photoModel.videoURL = videoAsset.URL;
                        if (self.photoModel.videoURL)
                        {
                            if ([self.playDelegate respondsToSelector:@selector(PVBrowseCollectionViewCell:playVideoByURL:)])
                            {
                                [self.playDelegate PVBrowseCollectionViewCell:self playVideoByURL:self.photoModel.videoURL];
                            }
                        }
                    });
                }
            }];
        }
        else
        {
            if ([self.playDelegate respondsToSelector:@selector(PVBrowseCollectionViewCell:playVideoByURL:)])
            {
                [self.playDelegate PVBrowseCollectionViewCell:self playVideoByURL:self.photoModel.videoURL];
            }
        }
    }
    else
    {
        if ([self.playDelegate respondsToSelector:@selector(PVBrowseCollectionViewCell:playVideoByURL:)])
        {
            [self.playDelegate PVBrowseCollectionViewCell:self playVideoByURL:self.photoModel.videoURL];
        }
    }
    
}
@end

//
//  PVPhotoCollectionViewCell.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVPhotoCollectionViewCell.h"
#import "PVPhotoModel.h"

@implementation PVPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.frame.size.height - 15, self.frame.size.width, 15)];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_timeLabel];
        _selectedCover = [[UILabel alloc] initWithFrame:_imageView.frame];
        _selectedCover.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.7];
        _selectedCover.hidden = YES;
        [self addSubview:_selectedCover];
    }
    return self;
}

- (void)setPhotoModel:(PVPhotoModel *)photoModel
{
    _photoModel = photoModel;
    if (photoModel.photo)
    {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = NO;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        __weak typeof(self) wself = self;
        [[PHImageManager defaultManager] requestImageForAsset:_photoModel.photo targetSize:CGSizeMake(200, 200) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            __strong typeof(wself) self = wself;
            self.imageView.image = result;
        }];
        if (photoModel.photo.mediaType == PHAssetMediaTypeVideo)
        {
            NSTimeInterval duration = photoModel.photo.duration;
            _timeLabel.text = [NSString stringWithFormat:@"%02.0f:%02td", duration/60.f, (NSInteger)duration%60];
            _timeLabel.hidden = NO;
        }
        else
        {
            _timeLabel.hidden = YES;
        }
    }
}

@end

//
//  PVBrowseCollectionViewCell.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@class PVPhotoModel;
@class PVBrowseCollectionViewCell;
@protocol PVVideoPlay <NSObject>

- (void)PVBrowseCollectionViewCell:(PVBrowseCollectionViewCell *)cell playVideoByURL:(NSURL *)url;

@end

@interface PVBrowseCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *playVideoButton;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, weak) id<PVVideoPlay> playDelegate;
@property (nonatomic, strong) PVPhotoModel *photoModel;

@end

NS_ASSUME_NONNULL_END

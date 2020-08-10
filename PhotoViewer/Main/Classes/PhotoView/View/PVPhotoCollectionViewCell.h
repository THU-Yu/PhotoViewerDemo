//
//  PVPhotoCollectionViewCell.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PVPhotoModel;
@interface PVPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *selectedCover;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) PVPhotoModel *photoModel;

@end

NS_ASSUME_NONNULL_END

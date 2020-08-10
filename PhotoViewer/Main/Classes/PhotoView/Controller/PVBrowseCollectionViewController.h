//
//  PVBrowseCollectionViewController.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@class PVPhotoModel;
@interface PVBrowseCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) BOOL isTopBarHidden;
@property (nonatomic, strong) NSArray *modelList;
@property (nonatomic, strong) PVPhotoModel *photoModel;

@end

NS_ASSUME_NONNULL_END

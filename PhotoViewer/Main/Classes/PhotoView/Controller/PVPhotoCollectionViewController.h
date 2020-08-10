//
//  PVPhotoCollectionViewController.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LDTabBarHidden <NSObject>

- (void)tabBarHidden:(BOOL)hidden;

@end

@interface PVPhotoCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) PHAssetCollection *photoAlbum;
@property (nonatomic, strong) PHFetchResult *fetchResult;
@property (nonatomic, strong) NSArray *modelList;
@property (nonatomic, strong) NSMutableArray *selectedModel;

@end

NS_ASSUME_NONNULL_END

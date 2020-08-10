//
//  PVAlbumTableViewController.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PVCameraViewController;
@interface PVAlbumTableViewController : UITableViewController

@property (nonatomic, strong)NSArray *photoListArray;
@property (nonatomic, strong) PVCameraViewController *cameraViewController;

- (void)getAlbumAuthorization;
- (void)fetchAllAlbumCollection;

@end

NS_ASSUME_NONNULL_END

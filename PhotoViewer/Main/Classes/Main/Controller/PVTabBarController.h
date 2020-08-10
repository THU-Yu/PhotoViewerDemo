//
//  PVTabBarController.h
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PVTabBarController : UITabBarController

@property (nonatomic, assign) BOOL didAddSubView;

- (void)setAllSubViewController;
- (void)setOneSubViewController:(UIViewController *)vc label:(NSString *)label color:(UIColor *)color image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END

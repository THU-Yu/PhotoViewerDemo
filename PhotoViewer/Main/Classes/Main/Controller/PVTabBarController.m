//
//  PVTabBarController.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVTabBarController.h"
#import "PVAlbumTableViewController.h"
#import "PVCameraViewController.h"

@interface PVTabBarController ()

@property(nonatomic, strong)NSMutableArray *items;

@end

//UITabBar

@implementation PVTabBarController

#pragma mark - Lazy Loading
- (NSMutableArray *)items
{
    if (!_items)
    {
        _items = [NSMutableArray array];
    }
    return _items;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set child view controller
    [self setAllSubViewController];
    
    _didAddSubView = NO;
}

#pragma mark - Set Sub View Controller
- (void)setAllSubViewController
{
    // Photo vc
    UITableViewController *photo = [[PVAlbumTableViewController alloc] init];
    [self setOneSubViewController:photo label:@"相册" color:[UIColor systemBackgroundColor] image:[UIImage imageNamed:@"photoIcon"]];
    // Camera vc
    PVCameraViewController *camera = [[PVCameraViewController alloc] init];
    [self setOneSubViewController:camera label:@"相机" color:[UIColor blackColor] image:[UIImage imageNamed:@"cameraIcon"]];
}

- (void)setOneSubViewController:(UIViewController *)vc label:(NSString *)label color:(UIColor *)color image:(UIImage *)image
{
    // Create navigationController
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
    
    vc.title = label;
    if (color != [UIColor clearColor])
    {
        vc.view.backgroundColor = color;
    }
    
    // Set tabBar
    vc.tabBarItem.image = image;
    vc.tabBarItem.title = label;
    [self.items addObject:vc.tabBarItem];
}
@end

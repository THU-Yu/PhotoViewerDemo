//
//  PVAlbumTableViewController.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVAlbumTableViewController.h"
#import "PVTabBarController.h"
#import "PVPhotoCollectionViewController.h"
#import <Photos/Photos.h>
#import "PVAlbumTableViewCell.h"
#import "PVCameraViewController.h"

@interface PVAlbumTableViewController ()

@end


@implementation PVAlbumTableViewController

#pragma mark - Get System Album
- (void)getAlbumAuthorization
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch(status)
    {
        // 许可状态未知
        case PHAuthorizationStatusNotDetermined:{
            __weak typeof (self) weakself = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                // 在主线程进行以下回调函数
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusAuthorized)
                    {
                        __strong typeof (weakself) self = weakself;
                        [self fetchAllAlbumCollection];
                        [self.tableView reloadData];
                    }
                    else
                    {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请到设置打开本APP的相册访问权限" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                });
            }];
            break;
        }
        // 用户允许访问
        case PHAuthorizationStatusAuthorized:{
            [self fetchAllAlbumCollection];
            break;
        }
        // 用户拒绝访问
        default:{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请到设置打开本APP的相册访问权限" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
    }
    
}

- (void)fetchAllAlbumCollection
{
    NSMutableArray *allAlbumMutableArray = [[NSMutableArray alloc] init];
    
    // Get system Album
    PHFetchResult<PHAssetCollection *> *systemAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    // Get custom Album
    PHFetchResult<PHAssetCollection *> *customAssetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    // IndexSet for selecting album
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, systemAssetCollections.count)];
    for (PHAssetCollection *collection in systemAssetCollections)
    {
        // Main album
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary)
        {
            [allAlbumMutableArray addObject:collection];
            [indexSet removeIndex:[systemAssetCollections indexOfObject:collection]];
        }
        // Hidden album
        else if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden)
        {
            [indexSet removeIndex:[systemAssetCollections indexOfObject:collection]];
        }
    }
    [allAlbumMutableArray addObjectsFromArray:[systemAssetCollections objectsAtIndexes:indexSet]];
    [allAlbumMutableArray addObjectsFromArray:[customAssetCollections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, customAssetCollections.count)]]];
    self.photoListArray = allAlbumMutableArray;
}

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set row height
    [self.tableView setRowHeight:50];
    
    if (!_photoListArray)
    {
        [self getAlbumAuthorization];
    }
    // Set the right button of the navigationBar
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] init];
    rightButton = [rightButton initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePhoto)];
    self.navigationItem.rightBarButtonItem = rightButton;
    _cameraViewController = [[PVCameraViewController alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Button Event
- (void)takePhoto
{
    [self.navigationController presentViewController:_cameraViewController animated:YES completion:^{}];
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"photo";
    UIImage *defaultImage = [UIImage imageNamed:@"defaultImageIcon"];
    
    // Get cell from cache pool, if not create a new cell
    PVAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell)
    {
        cell = [[PVAlbumTableViewCell alloc] init];
        cell = [cell initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.image = defaultImage;
    }
    
    // Setting the data of the cell
    // 1.Get the target album
    PHAssetCollection *photoAlbum = _photoListArray[indexPath.row];
    
    // 2.Search last photo in this album
    PHFetchResult *lastPhotoFetchResult = [PHAsset fetchAssetsInAssetCollection:photoAlbum options:nil];
    PHAsset *lastPhoto = lastPhotoFetchResult.lastObject;
    
    // 3.Transfer PHAsset to UIImage
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    // Set the imageView of the cell
    if (lastPhoto)
    {
        PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        [imageManager requestImageForAsset:lastPhoto targetSize:defaultImage.size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *resultImage, NSDictionary *info){
                UIImage *image = resultImage;
                cell.imageView.image = image;
            }];
    }
    else
    {
        cell.imageView.image = defaultImage;
    }
    
    // Set the text of the cell
    cell.textLabel.text = photoAlbum.localizedTitle;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",lastPhotoFetchResult.count];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Set the layout of the collectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    PVPhotoCollectionViewController *vc = [[PVPhotoCollectionViewController alloc] initWithCollectionViewLayout:layout];
    PHAssetCollection *photoAlbum = _photoListArray[indexPath.row];
    vc.photoAlbum = photoAlbum;
    vc.title = photoAlbum.localizedTitle;
    
    // hide the tabBar
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

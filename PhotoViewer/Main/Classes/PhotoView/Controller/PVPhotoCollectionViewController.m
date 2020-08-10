//
//  PVPhotoCollectionViewController.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVPhotoCollectionViewController.h"
#import "PVPhotoCollectionViewCell.h"
#import "PVBrowseCollectionViewController.h"
#import "PVCameraViewController.h"
#import "PVPhotoModel.h"

@interface PVPhotoCollectionViewController ()

@end

@implementation PVPhotoCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the collectionView
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = YES;
    
    // Register cell classes
    [self.collectionView registerClass:[PVPhotoCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Get All photo
    _fetchResult = [PHAsset fetchAssetsInAssetCollection:_photoAlbum options:nil];
    NSMutableArray *temp = [NSMutableArray array];
    for (PHAsset *photo in _fetchResult)
    {
        PVPhotoModel *model = [[PVPhotoModel alloc] init];
        model.photo = photo;
        model.playing = NO;
        model.isPause = NO;
        model.isSelected = NO;
        [temp addObject:model];
    }
    _modelList = temp;
    
    _selectedModel = [NSMutableArray array];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] init];
    rightButton = [rightButton initWithTitle:@"多选" style:UIBarButtonItemStyleDone target:self action:@selector(multipleSelected)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Show the navigationBar
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - Action
- (void)multipleSelected
{
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"多选"]) // Now is view mode, next to multiple select mode
    {
        self.navigationItem.rightBarButtonItem.title = @"取消";
    }
    else // Now is multiple select mode, next to view mode
    {
        // Clean all selection
        for (PVPhotoModel *model in _selectedModel)
        {
            model.isSelected = NO;
        }
        [_selectedModel removeAllObjects];
        
        // Clean all selected cover
        for (PVPhotoCollectionViewCell *cell in [self.collectionView visibleCells])
        {
            cell.selectedCover.hidden = YES;
        }
        self.navigationItem.rightBarButtonItem.title = @"多选";
    }
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger columeNumber = 4;
    NSInteger space = 2;
    CGFloat width = (self.collectionView.frame.size.width - (columeNumber - 1) * space) / 4;
    return CGSizeMake(width, width);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _modelList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PVPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    PVPhotoModel *model = _modelList[indexPath.row];
    // Configure the cell
    cell.photoModel = model;
    
    // Set selected cover by model
    cell.selectedCover.hidden = !model.isSelected;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PVPhotoCollectionViewCell *cell = (PVPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"多选"]) // Multiple select mode
    {
        PVPhotoModel *photoModel = [_modelList objectAtIndex:indexPath.row];
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        PVBrowseCollectionViewController *vc = [[PVBrowseCollectionViewController alloc] initWithCollectionViewLayout:layout];
        vc.photoModel = photoModel;
        vc.modelList = self.modelList;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else // View mode
    {
        PVPhotoModel *model = _modelList[indexPath.row];
        model.isSelected = !model.isSelected;
        if (model.isSelected) // Model is selected
        {
            [_selectedModel addObject:model];
            cell.selectedCover.hidden = NO;
        }
        else // Model isn't selected
        {
            [_selectedModel removeObject:model];
            cell.selectedCover.hidden = YES;
        }
    }
}

@end

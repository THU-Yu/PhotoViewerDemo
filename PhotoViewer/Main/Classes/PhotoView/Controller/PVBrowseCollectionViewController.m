//
//  PVBrowseCollectionViewController.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVBrowseCollectionViewController.h"
#import "PVBrowseCollectionViewCell.h"
#import "PVPhotoModel.h"

@interface PVBrowseCollectionViewController ()<PVVideoPlay>

@end

@implementation PVBrowseCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

#pragma mark - View Controller Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Uncomment the following line to preserve selection between presentations
    self.collectionView.scrollEnabled = YES;
    self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.collectionView.exclusiveTouch = YES;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator= NO;
    self.collectionView.showsVerticalScrollIndicator= NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor systemBackgroundColor];
    
    // Register cell classes
    [self.collectionView registerClass:[PVBrowseCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // Show the first photo
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:[self.modelList indexOfObject:self.photoModel] inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    // Do any additional setup after loading the view.
    _isTopBarHidden = NO;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionView.frame.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PVBrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.playDelegate = self;
    // Configure the cell
    cell.photoModel = [self.modelList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _isTopBarHidden = !_isTopBarHidden;
    /*
     self.navigationController.navigationBar.hidden只是将navigationBar隐藏不显示，而[self.navigationController setNavigationBarHidden:YES animated:YES]会将navigationController隐藏，因此会发生图片抖动一下才恢复原位。

     */
    PVBrowseCollectionViewCell *cell = (PVBrowseCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (cell.photoModel.photo.mediaType == PHAssetMediaTypeVideo)
    {
        cell.playVideoButton.hidden = !cell.playVideoButton.hidden;
    }
    self.navigationController.navigationBar.hidden = _isTopBarHidden;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Reset cell
    PVBrowseCollectionViewCell *myCell = (PVBrowseCollectionViewCell *)cell;
    [myCell.playVideoButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    myCell.photoModel.playing = NO;
    myCell.photoModel.isPause = NO;
    myCell.playerLayer.player = nil;
    
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:myCell.playerItem];
}

#pragma mark - PVVideoPlay
- (void)PVBrowseCollectionViewCell:(PVBrowseCollectionViewCell *)cell playVideoByURL:(NSURL *)url
{
    if (!cell.photoModel.playing) // Not playing now, next to play video
    {
        [cell.playVideoButton setImage:[UIImage imageNamed:@"stopButton"] forState:UIControlStateNormal];
        cell.photoModel.playing = YES;
    }
    else // Playing now, next to pause video
    {
        [cell.playVideoButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        cell.photoModel.playing = NO;
    }
    if (!cell.playerLayer.player) // First play video, need to set player
    {
        cell.playerItem = [AVPlayerItem playerItemWithURL:url];
        cell.player = [AVPlayer playerWithPlayerItem:cell.playerItem];
        cell.playerLayer.player = cell.player;
        [cell.player play];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:cell.playerItem];
    }
    else // Had set player, just want to play video or pause video
    {
        if (!cell.photoModel.isPause) // Playing now, next to pause video
        {
            cell.photoModel.isPause = YES;
            [cell.player pause];
        }
        else // Not playing now, next to playing video
        {
            cell.photoModel.isPause = NO;
            [cell.player play];
        }
    }
}

#pragma mark - NSNotificationCenter
- (void)videoPlayToEnd:(NSNotification *)notification
{
    // Reset player
    PVBrowseCollectionViewCell *cell = self.collectionView.visibleCells.firstObject;
    cell.playerLayer.player = nil;
    cell.photoModel.playing = NO;
    cell.photoModel.isPause = NO;
    [cell.playVideoButton setImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
    
    // Remove Observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:cell.playerItem];
}

@end

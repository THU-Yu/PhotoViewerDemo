//
//  PVAlbumTableViewCell.m
//  PhotoViewer
//
//  Created by admin on 2020/7/15.
//  Copyright © 2020 ChenYuHong. All rights reserved.
//

#import "PVAlbumTableViewCell.h"

@implementation PVAlbumTableViewCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Reset frame
    CGFloat space = 5;
    CGFloat imageX = space;
    CGFloat imageY = space;
    CGFloat imageW = 50;
    CGFloat imageH = self.frame.size.height - 2 * space;
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    self.imageView.clipsToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    CGFloat textX = CGRectGetMaxX(self.imageView.frame) + 2 * space;
    CGFloat textY = space;
    CGFloat textW = self.frame.size.width / 2;
    CGFloat textH = self.frame.size.height - 2 * space;
    self.textLabel.frame = CGRectMake(textX, textY, textW, textH);
    
    
}

@end

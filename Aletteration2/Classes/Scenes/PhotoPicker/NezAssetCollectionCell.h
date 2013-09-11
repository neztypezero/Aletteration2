//
//  NezAssetCollectionCell.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface NezAssetCollectionCell : UICollectionViewCell

@property(nonatomic,weak) IBOutlet UIImageView *assetImageView;
@property(nonatomic,weak,setter=setAsset:) ALAsset *asset;

@end

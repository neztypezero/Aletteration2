//
//  NezAssetCollectionCell.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAssetCollectionCell.h"

@implementation NezAssetCollectionCell

-(void)setAsset:(ALAsset*)asset {
	_asset = asset;
	_assetImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
}

@end

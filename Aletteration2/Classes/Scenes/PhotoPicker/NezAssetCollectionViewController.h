//
//  NezAssetCollectionViewController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NezPhotoPicker.h"

@interface NezAssetCollectionViewController : UICollectionViewController {
	NSMutableArray *_assetList;
	UIView *_overlayView;
}

@property(nonatomic,weak,setter=setAssetGroup:) ALAssetsGroup *assetGroup;

-(IBAction)cancelAction:(id)sender;

@end

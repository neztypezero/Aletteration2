//
//  NezPhotoPickerGroupCell.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface NezPhotoPickerGroupCell : UITableViewCell {
	
}

@property(nonatomic,weak) IBOutlet UIImageView *groupImageView;
@property(nonatomic,weak) IBOutlet UILabel *groupLabel;
@property(nonatomic,weak, setter = setAssetGroup:) ALAssetsGroup *assetGroup;

@end

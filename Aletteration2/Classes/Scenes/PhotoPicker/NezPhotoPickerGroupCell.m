//
//  NezPhotoPickerGroupCell.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezPhotoPickerGroupCell.h"

@implementation NezPhotoPickerGroupCell

-(void)setAssetGroup:(ALAssetsGroup *)assetGroup {
	_assetGroup = assetGroup;
	[self setGroupLabel:[assetGroup valueForProperty:ALAssetsGroupPropertyName] andCount:assetGroup.numberOfAssets];
	self.groupImageView.image = [UIImage imageWithCGImage:assetGroup.posterImage];
}

-(void)setGroupLabel:(NSString *)groupLabelText andCount:(int)count {
	NSString *countText = [NSString stringWithFormat:@" (%d)", count];
	NSString *text = [NSString stringWithFormat:@"%@%@", groupLabelText, countText];

    // iOS6 and above : Use NSAttributedStrings
    UIFont *boldFont = [UIFont boldSystemFontOfSize:self.groupLabel.font.pointSize];
    UIFont *regularFont = [UIFont systemFontOfSize:self.groupLabel.font.pointSize];
    UIColor *foregroundColor = [UIColor grayColor];
	
    // Create the attributes
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:boldFont, NSFontAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:regularFont, NSFontAttributeName, foregroundColor, NSForegroundColorAttributeName, nil];
	
    const NSRange range = NSMakeRange(groupLabelText.length,countText.length);
    // Create the attributed string (text + attributes)
    NSMutableAttributedString *attributedText =
	[[NSMutableAttributedString alloc] initWithString:text
										   attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];

    // Set it in our UILabel and we are done!
    [self.groupLabel setAttributedText:attributedText];
}

@end
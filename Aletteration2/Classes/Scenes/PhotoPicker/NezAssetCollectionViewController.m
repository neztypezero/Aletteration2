//
//  NezAssetCollectionViewController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAssetCollectionViewController.h"
#import "NezAssetCollectionCell.h"
#import "NezAssetCollectionFooterView.h"
#import "NezCropImageViewController.h"
#import "NezPhotoPickerNavigationController.h"

#define NEZ_LANDSCAPE_HEADER_HEIGHT 32+6
#define NEZ_PORTRAIT_HEADER_HEIGHT 44+6

@interface UIImage (Tint)

-(UIImage *)tintedImageUsingColor:(UIColor *)tintColor;

@end

@implementation UIImage (Tint)

-(UIImage*)tintedImageUsingColor:(UIColor *)tintColor {
	UIGraphicsBeginImageContext(self.size);
	CGRect drawRect = CGRectMake(0, 0, self.size.width, self.size.height);
	[self drawInRect:drawRect];
	[tintColor set];
	UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
	UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return tintedImage;
}

@end

@interface NezAssetCollectionViewController ()

@end

@implementation NezAssetCollectionViewController

-(void)viewDidLoad {
	NSLog(@"viewDidLoad");
	[super viewDidLoad];
	
	[self.view setUserInteractionEnabled:NO];
	_overlayView = [[UIView alloc] init];
	_overlayView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	_overlayView.frame = self.view.bounds;
	[self.view addSubview:_overlayView];
	
	UIView *superview = _overlayView;
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	[activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
	[activityIndicator startAnimating];
	[superview addSubview:activityIndicator];
	
	NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
	[superview addConstraint:cn];
	
	cn = [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
	[superview addConstraint:cn];
}

-(void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	if (_overlayView) {
		_overlayView.frame = self.view.bounds;
	}
	UICollectionViewFlowLayout *collectionViewLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
	UIInterfaceOrientation interfaceOrientation = self.interfaceOrientation;
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		if (collectionViewLayout.headerReferenceSize.height != NEZ_LANDSCAPE_HEADER_HEIGHT) {
			collectionViewLayout.headerReferenceSize = CGSizeMake(0, NEZ_LANDSCAPE_HEADER_HEIGHT);
		}
	} else {
		if (collectionViewLayout.headerReferenceSize.height != NEZ_PORTRAIT_HEADER_HEIGHT) {
			collectionViewLayout.headerReferenceSize = CGSizeMake(0, NEZ_PORTRAIT_HEADER_HEIGHT);
		}
	}
}

-(void)viewDidAppear:(BOOL)animated {
	if (_assetList == nil) {
		NSMutableArray *assetList = [NSMutableArray arrayWithCapacity:_assetGroup.numberOfAssets];
		[_assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
			if(result != nil) {
				[assetList setObject:result atIndexedSubscript:index];
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					[UIView animateWithDuration:0.25 animations:^{
						_overlayView.alpha = 0.0;
					} completion:^(BOOL finished) {
						[_overlayView removeFromSuperview];
						_overlayView = nil;
						[self.view setUserInteractionEnabled:YES];
					}];
					_assetList = assetList;
					[self.collectionView reloadData];
				});
			}
		}];
	}
}

-(IBAction)cancelAction:(id)sender {
	NezPhotoPickerNavigationController *navController = (NezPhotoPickerNavigationController*)self.navigationController;
	[navController cancel];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowAssetSegue"]) {
		NezAssetCollectionCell *assetCell = sender;
		NezCropImageViewController *cropImageViewController = segue.destinationViewController;
		cropImageViewController.asset = assetCell.asset;
	}
}

-(void)setAssetGroup:(ALAssetsGroup*)assetGroup {
	_assetList = nil;
	_assetGroup = assetGroup;
	[self setTitle:[assetGroup valueForProperty:ALAssetsGroupPropertyName]];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	if (_assetList) {
		return _assetList.count;
	} else {
		return 0;
	}
}

-(UICollectionReusableView *)collectionView: (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
	if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
		UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
		return headerView;
	} else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
		NezAssetCollectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
		footerView.photoCountLabel.text = [NSString stringWithFormat:@"%d Photo%c", _assetList.count, _assetList.count==1?'\0':'s'];
		return footerView;
	}
	return nil;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NezAssetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AssetCollectionCell" forIndexPath:indexPath];
	cell.asset = [_assetList objectAtIndex:indexPath.row];
	return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	NezAssetCollectionCell *cell = (NezAssetCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
	cell.assetImageView.highlightedImage = [cell.assetImageView.image tintedImageUsingColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
	cell.assetImageView.highlighted = YES;
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	NezAssetCollectionCell *cell = (NezAssetCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
	cell.assetImageView.highlighted = NO;
	cell.assetImageView.highlightedImage = nil;
}

@end

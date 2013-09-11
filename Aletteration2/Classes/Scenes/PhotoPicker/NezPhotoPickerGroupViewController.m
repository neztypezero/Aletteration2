//
//  NezPhotoPickerTableViewController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-29.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezPhotoPickerGroupViewController.h"
#import "NezPhotoPickerGroupCell.h"
#import "NezAssetCollectionViewController.h"
#import "NezPhotoPickerNavigationController.h"

@interface NezPhotoPickerGroupViewController ()

@end

@implementation NezPhotoPickerGroupViewController

-(void)viewDidLoad {
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
	if (_overlayView) {
		_overlayView.frame = self.view.bounds;
	}
}

-(void)viewDidAppear:(BOOL)animated {
	if (_photoPicker == nil) {
		_photoPicker = [[NezPhotoPicker alloc] init];
		[self loadGroupSections];
	}
}

-(void)loadGroupSections {
	[_photoPicker loadGroupsWithOnFinishBlock:^{
		[UIView animateWithDuration:0.25 animations:^{
			_overlayView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_overlayView removeFromSuperview];
			_overlayView = nil;
			[self.tableView setUserInteractionEnabled:YES];
		}];
		[self.tableView reloadData];
	}];
}

-(IBAction)cancelAction:(id)sender {
	NezPhotoPickerNavigationController *navController = (NezPhotoPickerNavigationController*)self.navigationController;
	[navController cancel];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AssetGroupSegue"]) {
		NezPhotoPickerGroupCell *groupCell = sender;
		NezAssetCollectionViewController *assetCollectionViewController = segue.destinationViewController;
		assetCollectionViewController.assetGroup = groupCell.assetGroup;
	}
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([_photoPicker finishLoadingGroupScetions]) {
		return _photoPicker.groupSectionList.count;
	} else {
    	return 0;
	}
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if ([_photoPicker finishLoadingGroupScetions]) {
		NSArray *groupArray = [_photoPicker.groupSectionList objectAtIndex:section];
		return groupArray.count;
	} else {
    	return 0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PhotoPickerCell";
    NezPhotoPickerGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NSArray *groupArray = [_photoPicker.groupSectionList objectAtIndex:indexPath.section];
    ALAssetsGroup *assetGroup = [groupArray objectAtIndex:indexPath.row];
	
	cell.assetGroup = assetGroup;
	
    return cell;
}

@end

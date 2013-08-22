//
//  NezPlayerCollectionController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-26.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezPlayerCollectionController.h"
#import "NezPlayerCollectionViewCell.h"

@interface NezPlayerCollectionController ()

@end

@implementation NezPlayerCollectionController

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 1;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NezPlayerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PlayerCell" forIndexPath:indexPath];
	return cell;
}

@end

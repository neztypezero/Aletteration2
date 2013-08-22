//
//  NezHighScoreCell.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezHighScoreCell.h"

@implementation NezHighScoreCell

-(void)setHighScoreItem:(NezAletterationSQLiteHighScoreItem*)hsItem {
	_item = hsItem;
	self.name.text = hsItem.name;
	self.date.text = hsItem.date;
	self.score.text = [NSString stringWithFormat:@"%d", hsItem.score];
}

@end

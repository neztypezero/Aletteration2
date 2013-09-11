//
//  NezHighScoreCell.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezSQLiteHighScores.h"

@interface NezHighScoreCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UILabel *score;


@property (nonatomic, strong, setter = setHighScoreItem:) NezAletterationSQLiteHighScoreItem *item;

@end

//
//  NezHighScoreTableController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NezHighScoreWordsTableController;

@interface NezHighScoreTableController : UITableViewController

@property (nonatomic, strong) IBOutlet NezHighScoreWordsTableController *wordsTable;

@property (nonatomic, strong) NSArray *highScoreList;

@end

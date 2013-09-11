//
//  NezHighScoreWordsTableController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NezHighScoreWordsTableController : UITableViewController

@property (nonatomic, weak, setter = setWordList:) NSArray *wordList;

@end

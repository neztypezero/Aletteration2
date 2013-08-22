//
//  NezHighScoresController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezEmbededDialogController.h"

@class NezHighScoreTableController;
@class NezHighScoreWordsTableController;

@interface NezHighScoresController : NezEmbededDialogController

@property (nonatomic, weak) IBOutlet NezHighScoreTableController *highscoresTable;
@property (nonatomic, weak) IBOutlet NezHighScoreWordsTableController *wordsTable;

@end

//
//  NezHighScoresController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezHighScoresController.h"
#import "NezHighScoreTableController.h"
#import "NezHighScoreWordsTableController.h"

@interface NezHighScoresController ()

@end

@implementation NezHighScoresController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HighScoresSegue"]) {
		self.highscoresTable = segue.destinationViewController;
	} else if ([segue.identifier isEqualToString:@"HighScoreWordsSegue"]) {
		self.wordsTable = segue.destinationViewController;
	}
	if (self.highscoresTable != nil && self.wordsTable != nil) {
		self.highscoresTable.wordsTable = self.wordsTable;
		self.highscoresTable = nil;
		self.wordsTable = nil;
	}
}

@end

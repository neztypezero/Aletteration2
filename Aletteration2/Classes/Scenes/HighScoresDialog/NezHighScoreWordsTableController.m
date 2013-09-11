//
//  NezHighScoreWordsTableController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezHighScoreWordsTableController.h"
#import "NezSQLiteHighScores.h"

@interface NezHighScoreWordsTableController ()

@end

@implementation NezHighScoreWordsTableController

-(void)setWordList:(NSArray*)wList {
	_wordList = wList;
	[self.tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.wordList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NezSQLiteHighScoreWord *wordItem = [self.wordList objectAtIndex:indexPath.row];
    cell.textLabel.text = wordItem.word;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"Word List";
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *CellIdentifier = @"WordsHeader";
//    NezSectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil){
//        [NSException raise:@"cell == nil.." format:@"No cells with matching CellIdentifier loaded from interface builder"];
//    }
//	cell.title.text = [self tableView:tableView titleForHeaderInSection:section];
//    return (UIView *)cell;
//}

@end

//
//  NezHighScoreTableController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-20.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezHighScoreTableController.h"
#import "NezHighScoreCell.h"
#import "NezHighScoreWordsTableController.h"
#import "NezSQLiteHighScores.h"
#import "NezGCD.h"

@interface NezHighScoreTableController ()

@end

@implementation NezHighScoreTableController

-(void)viewDidLayoutSubviews {
	if (self.highScoreList == nil) {
		self.highScoreList = [NezSQLiteHighScores getHighScoreListWithLimit:20];
		if (self.highScoreList.count > 0) {
			NezAletterationSQLiteHighScoreItem *item = [self.highScoreList objectAtIndex:0];
			[NezSQLiteHighScores getHighScoreWordListWithHighScoreItem:item];
		}
		[self.tableView reloadData];
		if (self.highScoreList.count > 0) {
			NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
			[self.tableView selectRowAtIndexPath:path animated:NO scrollPosition:UITableViewScrollPositionTop];
			[self tableView:self.tableView didSelectRowAtIndexPath:path];
		}
	}
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.highScoreList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"HighScoreCell";
    NezHighScoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	NezAletterationSQLiteHighScoreItem *item = [self.highScoreList objectAtIndex:indexPath.row];
	cell.item = item;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return @"High Scores";
}

//-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    static NSString *CellIdentifier = @"HighScoreHeader";
//    NezSectionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil){
//        [NSException raise:@"cell == nil.." format:@"No cells with matching CellIdentifier loaded from interface builder"];
//    }
//	cell.title.text = [self tableView:tableView titleForHeaderInSection:section];
//    return (UIView *)cell;
//}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NezAletterationSQLiteHighScoreItem *item = [self.highScoreList objectAtIndex:indexPath.row];
	if (item.wordList == nil) {
		[NezSQLiteHighScores getHighScoreWordListWithHighScoreItem:item];
	}
	self.wordsTable.wordList = item.wordList;
}

@end

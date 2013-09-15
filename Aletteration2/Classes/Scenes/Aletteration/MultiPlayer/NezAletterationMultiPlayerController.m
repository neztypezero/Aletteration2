//
//  NezAletterationMultiPlayerController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-22.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationMultiPlayerController.h"
#import "NezAletterationGameState.h"
#import "NezAletterationAnimationInitial.h"

@implementation NezAletterationMultiPlayerController

-(void)viewDidLoad {
	_networkState = kNezAletterationNetworkStateWaitingForMatch;
	[NezAletterationGameState reset];
}

-(void)viewDidAppear:(BOOL)animated {
	[[NezGameCenter sharedInstance] findMatchWithMinPlayers:2 maxPlayers:4 viewController:self delegate:self];
}

-(void)startGameUsingCurrentStateObject {
	_networkState = kNezAletterationNetworkStateActive;
	[NezAletterationAnimationInitial doAnimationFor:self WithStopBlock:^(NezAnimation *ani) {
		[self startNextTurn];
	}];
}

-(void)matchStarted {
	NSLog(@"Match Started!!!");
	_networkState = kNezAletterationNetworkStateWaitingForStart;
	
	NSArray *playerIdList = [[NezGameCenter sharedInstance].playerIdList sortedArrayUsingSelector:@selector(compare:)];
	
	//If the local player is alphabetically first in the list then send that letter list to the other players
	if ([playerIdList.firstObject isEqualToString:[NezGameCenter sharedInstance].localPlayerId]) {
		[self sendLetterListWithDataSentBlock:^(BOOL success, NSError *error) {
			if (success) {
				[self startGameUsingCurrentStateObject];
			} else {
				NSLog(@"%@", error);
			}
		}];
	}
}

-(void)matchEnded {
	
}

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    NezAletterationNetworkMessage *message = (NezAletterationNetworkMessage*)[data bytes];
	switch (message->messageType) {
		case kNezAletterationNetworkMessageTypeLetterList: {
			NezAletterationNetworkMessageLetterList *letterListMessage = (NezAletterationNetworkMessageLetterList*)[data bytes];
			NSLog(@"didReceiveData:%s", letterListMessage->letterList);
			[[NezAletterationGameState getPreferences].stateObject useLetterList:letterListMessage->letterList];
			[self startGameUsingCurrentStateObject];
			break;
		} case kNezAletterationNetworkMessageTypeGameBegin: {
			break;
		} case kNezAletterationNetworkMessageTypeLetterBlockPlaced: {
			break;
		} case kNezAletterationNetworkMessageTypeWordRetired: {
			break;
		} case kNezAletterationNetworkMessageTypeGameOver: {
			break;
		} default: {
			break;
		}
	}
}

-(void)sendLetterListWithDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock {
	NezAletterationNetworkMessageLetterList letterListMessage;
	letterListMessage.message.messageType = kNezAletterationNetworkMessageTypeLetterList;
	[[NezAletterationGameState getPreferences].stateObject copyLetterList:letterListMessage.letterList];
	NSData *data = [NSData dataWithBytes:&letterListMessage length:sizeof(NezAletterationNetworkMessageLetterList)];

	[[NezGameCenter sharedInstance] sendDataReliable:data withDataSentBlock:dataSentBlock];

	NSLog(@"sendLetterList:%s", letterListMessage.letterList);
}

@end

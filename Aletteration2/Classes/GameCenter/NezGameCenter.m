//
//  NezGameCenter.m
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-13.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//
#import "NezGameCenter.h"

@implementation NezGameCenter

static NezGameCenter *gGameCenterInstance = nil;

+(void)initialize {
    if (!gGameCenterInstance) {
        gGameCenterInstance = [[NezGameCenter alloc] init];
    }
}

+(NezGameCenter*)sharedInstance {
	return gGameCenterInstance;
}

-(id)init {
    if ((self = [super init])) {
		// I am targeting iOS7 so I do not need to check for GameCenter availability
    }
    return self;
}

-(void)authenticateLocalUserWithHandler:(NezGameCenterAuthenticationBlock)handler {
    NSLog(@"Authenticating local user...");
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if (localPlayer.authenticated == NO) {
		localPlayer.authenticateHandler = handler;
    } else {
        NSLog(@"localPlayer authenticated!");
    }
}

-(void)lookupPlayers {
	GKMatch *match = self.match;
	
    NSLog(@"Looking up %d players...", match.playerIDs.count);
    [GKPlayer loadPlayersForIdentifiers:match.playerIDs withCompletionHandler:^(NSArray *players, NSError *error) {
        if (error != nil) {
            NSLog(@"Error retrieving player info: %@", error.localizedDescription);
            _matchStarted = NO;
            [self.delegate matchEnded];
        } else {
            // Populate players dict
            self.playersDict = [NSMutableDictionary dictionaryWithCapacity:players.count+1];
            for (GKPlayer *player in players) {
                NSLog(@"Found player: %@", player.alias);
                [self.playersDict setObject:player forKey:player.playerID];
            }
			GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
			NSLog(@"Added local player: %@", localPlayer.alias);
			[self.playersDict setObject:localPlayer forKey:localPlayer.playerID];
			
            // Notify delegate match can begin
            _matchStarted = YES;
            [self.delegate matchStarted];
        }
    }];
}

-(NSArray*)getPlayerIdList {
	return [self.playersDict allKeys];
}

-(NSString*)getLocalPlayerId {
	GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
	return localPlayer.playerID;
}

-(void)sendDataReliable:(NSData*)data withDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock {
	NSError *error;
	BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
	if (dataSentBlock) {
		dataSentBlock(success, error);
	}
}

-(void)sendDataUnreliable:(NSData*)data withDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock {
	NSError *error;
	BOOL success = [self.match sendDataToAllPlayers:data withDataMode:GKMatchSendDataUnreliable error:&error];
	if (dataSentBlock) {
		dataSentBlock(success, error);
	}
}

-(void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController*)viewController delegate:(id<NezGameCenterDelegate>)delegate {
	_matchStarted = NO;
    self.match = nil;
    self.presentingViewController = viewController;
    self.delegate = delegate;
    [self.presentingViewController dismissViewControllerAnimated:NO completion:^{}];
	
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = minPlayers;
    request.maxPlayers = maxPlayers;
	
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
	
    [self.presentingViewController presentViewController:mmvc animated:YES completion:^{}];
}

#pragma mark GKMatchmakerViewControllerDelegate

// The user has cancelled matchmaking
-(void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		NSLog(@"matchmakerViewControllerWasCancelled");
	}];
}

// Matchmaking has failed with an error
-(void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		NSLog(@"Error finding match: %@", error.localizedDescription);
	}];
}

// A peer-to-peer match has been found, the game should start
-(void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
		self.match = match;
		self.match.delegate = self;
		if (!_matchStarted && match.expectedPlayerCount == 0) {
			NSLog(@"Ready to start match!");
			[self lookupPlayers];
		}
	}];
}

#pragma mark GKMatchDelegate

// The match received data sent from the player.
-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    if (self.match != match) return;
	
    [self.delegate match:match didReceiveData:data fromPlayer:playerID];
}

// The player state changed (eg. connected or disconnected)
-(void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    if (self.match != match) return;
	
    switch (state) {
        case GKPlayerStateConnected:
            // handle a new player connection.
            NSLog(@"Player connected!");
            break;
        case GKPlayerStateDisconnected:
            // a player just disconnected.
            NSLog(@"Player disconnected!");
            _matchStarted = NO;
            [self.delegate matchEnded];
            break;
    }
}

// The match was unable to connect with the player due to an error.
-(void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error {
    if (self.match != match) return;
	
    NSLog(@"Failed to connect to player with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [self.delegate matchEnded];
}

// The match was unable to be established with any players due to an error.
-(void)match:(GKMatch *)match didFailWithError:(NSError *)error {
	
    if (self.match != match) return;
	
    NSLog(@"Match failed with error: %@", error.localizedDescription);
    _matchStarted = NO;
    [self.delegate matchEnded];
}

@end

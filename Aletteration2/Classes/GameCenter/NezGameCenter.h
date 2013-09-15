//
//  NezGameCenter.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-13.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

typedef void(^NezGameCenterAuthenticationBlock)(UIViewController *viewController, NSError *error);
typedef void(^NezGameCenterDataSentBlock)(BOOL success, NSError *error);

@protocol NezGameCenterDelegate
-(void)matchStarted;
-(void)matchEnded;
-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
@end

@interface NezGameCenter : NSObject<GKMatchmakerViewControllerDelegate, GKMatchDelegate> {
	BOOL _matchStarted;
}

@property (strong) UIViewController *presentingViewController;
@property (strong) GKMatch *match;
@property (strong) id<NezGameCenterDelegate> delegate;
@property (strong) NSMutableDictionary *playersDict;
@property (readonly, getter = getLocalPlayerId) NSString *localPlayerId;
@property (readonly, getter = getPlayerIdList) NSArray *playerIdList;

+(NezGameCenter*)sharedInstance;
-(void)authenticateLocalUserWithHandler:(NezGameCenterAuthenticationBlock)handler;

-(void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers viewController:(UIViewController*)viewController delegate:(id<NezGameCenterDelegate>)delegate;
-(NSArray*)getPlayerIdList;

#pragma mark Send Data

-(void)sendDataReliable:(NSData*)data withDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock;
-(void)sendDataUnreliable:(NSData*)data withDataSentBlock:(NezGameCenterDataSentBlock)dataSentBlock;

#pragma mark GKMatchmakerViewControllerDelegate

-(void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController;
-(void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error;
-(void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match;

#pragma mark GKMatchDelegate

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID;
-(void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state;
-(void)match:(GKMatch *)match connectionWithPlayerFailed:(NSString *)playerID withError:(NSError *)error;
-(void)match:(GKMatch *)match didFailWithError:(NSError *)error;

@end
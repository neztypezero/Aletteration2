//
//  NezAletterationMultiPlayerController.h
//  Aletteration2
//
//  Created by David Nesbitt on 2013-09-13.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationSinglePlayerController.h"
#import "NezGameCenter.h"

typedef enum {
    kNezAletterationNetworkStateWaitingForMatch = 0,
    kNezAletterationNetworkStateWaitingForStart,
    kNezAletterationNetworkStateActive,
    kNezAletterationNetworkStateDone
} NezAletterationNetworkState;

typedef enum {
    kNezAletterationNetworkMessageTypeLetterList = 0,
    kNezAletterationNetworkMessageTypeGameBegin,
    kNezAletterationNetworkMessageTypeLetterBlockPlaced,
    kNezAletterationNetworkMessageTypeWordRetired,
    kNezAletterationNetworkMessageTypeGameOver
} NezAletterationNetworkMessageType;

typedef struct {
    NezAletterationNetworkMessageType messageType;
} NezAletterationNetworkMessage;

typedef struct {
    NezAletterationNetworkMessage message;
    char letterList[91];
} NezAletterationNetworkMessageLetterList;


@interface NezAletterationMultiPlayerController : NezAletterationSinglePlayerController<NezGameCenterDelegate> {
	NezAletterationNetworkState _networkState;
}

@end

//
//  NezOpenALPlayer.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-27.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezOpenALPlayer.h"
#import "NezOpenAL.h"

@implementation NezOpenALSoundLoader

-(id)initWithSoundPlayer:(NezOpenAL*)soundPlayer {
	if ((self = [super init])) {
		_intro = [soundPlayer loadSoundEffectWithPathForResource:@"introSound" ofType:@"caf" inDirectory:@"Sounds"];
		_tileDrop = [soundPlayer loadSoundEffectWithPathForResource:@"tileDrop" ofType:@"caf" inDirectory:@"Sounds"];
		_dblTapWord = [soundPlayer loadSoundEffectWithPathForResource:@"dblTapWord" ofType:@"caf" inDirectory:@"Sounds"];
		_letterUp = [soundPlayer loadSoundEffectWithPathForResource:@"letterUp" ofType:@"caf" inDirectory:@"Sounds"];
		_letterDown = [soundPlayer loadSoundEffectWithPathForResource:@"letterDown" ofType:@"caf" inDirectory:@"Sounds"];
		_touchLetter = [soundPlayer loadSoundEffectWithPathForResource:@"touchLetter" ofType:@"caf" inDirectory:@"Sounds"];
		_lockLetter = [soundPlayer loadSoundEffectWithPathForResource:@"lockLetter" ofType:@"caf" inDirectory:@"Sounds"];
		_wordMove = [soundPlayer loadSoundEffectWithPathForResource:@"wordMove" ofType:@"caf" inDirectory:@"Sounds"];
		_fireworks = [soundPlayer loadSoundEffectWithPathForResource:@"fireworks" ofType:@"caf" inDirectory:@"Sounds"];
		_scoreCounter = [soundPlayer loadSoundEffectWithPathForResource:@"scoreCounter" ofType:@"caf" inDirectory:@"Sounds"];
		_scoreFadeIn = [soundPlayer loadSoundEffectWithPathForResource:@"scoreFadeIn" ofType:@"caf" inDirectory:@"Sounds"];
	}
	return self;
}

@end

@implementation NezOpenALPlayer

-(id)initWithEnabled:(BOOL)enabled Volume:(float)volume {
	if ((self = [super init])) {
		_soundPlayer = [[NezOpenAL alloc] init];
		
		_loadedSounds = [[NezOpenALSoundLoader alloc] initWithSoundPlayer:_soundPlayer];
		
		_soundPlayer.isEnabled = enabled;
		_soundPlayer.listenerGain = volume;
	}
	return self;
}

-(void)playSound:(unsigned int)sound withPitch:(float)pitch {
	[_soundPlayer playSound:sound gain:1.0 pitch:pitch loops:NO];
}

@end

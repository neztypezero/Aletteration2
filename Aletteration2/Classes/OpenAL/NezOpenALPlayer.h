//
//  NezOpenALPlayer.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-27.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NezOpenAL;

@interface NezOpenALSoundLoader : NSObject

@property(nonatomic, readonly) unsigned int intro;
@property(nonatomic, readonly) unsigned int tileDrop;
@property(nonatomic, readonly) unsigned int dblTapWord;
@property(nonatomic, readonly) unsigned int letterUp;
@property(nonatomic, readonly) unsigned int letterDown;
@property(nonatomic, readonly) unsigned int touchLetter;
@property(nonatomic, readonly) unsigned int lockLetter;
@property(nonatomic, readonly) unsigned int wordMove;
@property(nonatomic, readonly) unsigned int fireworks;
@property(nonatomic, readonly) unsigned int scoreCounter;
@property(nonatomic, readonly) unsigned int scoreFadeIn;

@end

@interface NezOpenALPlayer : NSObject {
	NezOpenAL *_soundPlayer;
}

@property(nonatomic, readonly) NezOpenALSoundLoader *loadedSounds;

-(id)initWithEnabled:(BOOL)enabled Volume:(float)volume;

-(void)playSound:(unsigned int)sound withPitch:(float)pitch;

@end

//
//  NezAVAudioPlayer.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-27.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface NezAVAudioPlayer : NSObject<AVAudioPlayerDelegate> {
	BOOL _musicEnabled;
	BOOL _musicInterupted;
	BOOL _musicPlaying;
	AVAudioPlayer *_musicPlayer;
	UInt32 _otherMusicIsPlaying;
}

@property(nonatomic, readonly, getter = getIsPlaying) BOOL isPlaying;

-(id)initWithSongName:(NSString*)songName NumberOfLoops:(int)loops Enabled:(BOOL)enabled Volume:(float)volume;

-(void)setMusicVolume:(float)volume;
-(void)setMusicEnabled:(BOOL)isEnabled;
-(void)stopMusic;
-(void)tryPlayMusic;

@end

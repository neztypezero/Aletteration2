//
//  NezAVAudioPlayer.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-27.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#import "NezAVAudioPlayer.h"
#import "NezAletterationGameState.h"

@implementation NezAVAudioPlayer

-(id)initWithSongName:(NSString*)songName NumberOfLoops:(int)loops Enabled:(BOOL)enabled Volume:(float)volume {
	if ((self = [super init])) {
		// Set up the audio session
		// See handy chart on pg. 55 of the Audio Session Programming Guide for what the categories mean
		// Not absolutely required in this example, but good to get into the habit of doing
		// See pg. 11 of Audio Session Programming Guide for "Why a Default Session Usually Isn't What You Want"
		NSError *setCategoryError = nil;
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
		
		// Create audio player with background music
		NSString *backgroundMusicPath = [[NSBundle mainBundle] pathForResource:songName ofType:@"m4a" inDirectory:@"Music"];
		NSURL *backgroundMusicURL = [NSURL fileURLWithPath:backgroundMusicPath];
		NSError *error;
		_musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
		[_musicPlayer setDelegate:self];  // We need this so we can restart after interruptions
		[_musicPlayer setNumberOfLoops:loops];	// Negative number means loop forever
		
		_musicPlaying = NO;
		_musicEnabled = enabled;
		[self setMusicVolume:volume];
		
	}
	return self;
}

-(void)setMusicVolume:(float)volume {
	[_musicPlayer setVolume:volume];
}

-(void)setMusicEnabled:(BOOL)isEnabled {
	if (_musicEnabled != isEnabled) {
		_musicEnabled = isEnabled;
		if (_musicEnabled) {
			[self tryPlayMusic];
		}
	}
}

-(void)stopMusic {
	if (_musicPlaying) {
		[_musicPlayer stop];
		[_musicPlayer setCurrentTime:0];
		_musicPlaying = NO;
	}
}

-(void)playMusic {
	[_musicPlayer setCurrentTime:0];
    [_musicPlayer prepareToPlay];
    [_musicPlayer play];
	_musicPlaying = YES;
}

-(void)tryPlayMusic {
	// Check to see if iPod music is already playing
	UInt32 propertySize = sizeof(_otherMusicIsPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &_otherMusicIsPlaying);
	
	// Play the music if no other music is playing and we aren't playing already
	if (_otherMusicIsPlaying != 1 && !_musicPlaying && _musicEnabled) {
        [self playMusic];
	}
}

-(BOOL)getIsPlaying {
	return _musicPlaying;
}

#pragma AVAudioPlayerDelegate functions

-(void)audioPlayerBeginInterruption:(AVAudioPlayer*)player {
	_musicInterupted = YES;
}

-(void)audioPlayerEndInterruption:(AVAudioPlayer*)player {
	if (_musicInterupted) {
		[self tryPlayMusic];
		_musicInterupted = NO;
	}
}

@end

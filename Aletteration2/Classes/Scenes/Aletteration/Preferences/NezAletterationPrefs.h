//
//  NezAletterationPrefs.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-21.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@class NezAletterationWordState;

@interface NezAletterationWordState : NSObject<NSCoding>

@property(nonatomic) int32_t state;
@property(nonatomic) int32_t index;
@property(nonatomic) int32_t length;

+(NezAletterationWordState*)wordState;
+(NezAletterationWordState*)wordStateCopy:(NezAletterationWordState*)wordState;

@end

@class NezAletterationLetterBlock;

@interface NezAletterationGameStateRetiredWord : NSObject<NSCoding>

@property(nonatomic) int32_t lineIndex;
@property(nonatomic) NSRange range;

@end

@interface NezAletterationGameStateTurn : NSObject<NSCoding>

@property(nonatomic) int32_t temporaryLineIndex;
@property(nonatomic) int32_t lineIndex;
@property(nonatomic, strong) NSMutableArray *retiredWordList;

@end

@interface NezAletterationGameStateObject : NSObject<NSCoding>

@property(nonatomic, strong) NSMutableData *letterData;
@property(nonatomic, strong) NSMutableArray *turnStack;
@property(nonatomic, readonly, getter = getTurn) int turn;
@property(nonatomic, readonly, getter = getLetterList) char *letterList;
@property(nonatomic, strong) UIImage *snapshot;
@property(nonatomic, readonly, getter = getCurrentTurn) NezAletterationGameStateTurn *currentTurn;
@property(nonatomic, strong) NSMutableArray *lineStateStackList;

+(id)stateObject;

-(void)copyLetterList:(char*)dstLetterList;
-(void)useLetterList:(char*)srcLetterList;

-(void)reset;
-(void)endTurn:(int)lineIndex;
-(void)pushNextTurn;

-(NSMutableArray*)getWordStateStackForLineIndex:(int)lineIndex;
-(void)pushWordState:(NezAletterationWordState*)state forLineIndex:(int)lineIndex;
-(NezAletterationWordState*)getTopWordStateForLineIndex:(int)lineIndex;
-(void)removeWordStateInRange:(NSRange)range forLineIndex:(int)lineIndex;

@end

@interface NezAletterationPrefsObject : NSObject<NSCoding>

@property(nonatomic) BOOL firstTime;
@property(nonatomic, strong) NSString *playerName;
@property(nonatomic, strong) UIImage *playerPortrait;
@property(nonatomic) GLKVector4 blockColor;
@property(nonatomic) BOOL musicEnabled;
@property(nonatomic) float musicVolume;
@property(nonatomic) BOOL soundEnabled;
@property(nonatomic) float soundVolume;
@property(nonatomic, strong) NezAletterationGameStateObject *stateObject;

+(id)preferencesName:(NSString*)name Portrait:(UIImage*)potrait Color:(GLKVector4)color MusicEnabled:(BOOL)musicEnabled MusicVolume:(float)musicVolume SoundEnabled:(BOOL)soundEnabled SoundVolume:(float)soundVolume;
-(id)initName:(NSString*)name Portrait:(UIImage*)potrait Color:(GLKVector4)color MusicEnabled:(BOOL)musicEnabled MusicVolume:(float)musicVolume SoundEnabled:(BOOL)soundEnabled SoundVolume:(float)soundVolume;

@end

@interface NezAletterationPrefs : NSObject

+(NezAletterationPrefsObject*)getPreferences;
+(void)setPreferences:(NezAletterationPrefsObject*)prefs;

@end

//
//  NezAletterationGameState.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-25.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezAletterationGameState.h"
#import "NezVertexArray.h"
#import "NezCamera.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationDisplayLine.h"
#import "NezGLSLProgram.h"
#import "NezOpenAL.h"
#import "NezGCD.h"
#import "NezAVAudioPlayer.h"
#import "NezOpenALPlayer.h"
#import "NezAletterationBackground.h"
#import "NezAletterationBox.h"
#import "NezAletterationLid.h"
#import "NezAletterationRaysRectangle.h"
#import "NezAletterationLetterStack.h"
#import "NezAletterationPrefs.h"
#import "NezAletterationSQLiteDictionary.h"
#import "NezAletterationRetiredWord.h"
#import "NezAletterationScoreboard.h"

static BOOL gInitialStateSet = NO;

static const int ALETTERATION_LETTER_BAG[] = {
	5, 2, 4, 4, 10, 2, 3, 4, 5, 1, 2, 4, 3,
	5, 5, 3, 1, 5,  5, 5, 4, 2, 2, 1, 2, 1,
};

static int ALETTERATION_LETTER_COUNT = 0;
static CGRect ALETTERATION_LOGO_FRAME;

typedef enum ShaderTypes {
	NEZ_SHADER_COLORED,
	NEZ_SHADER_COLORED_ONE_MINUS_SRC_ALPHA,
	NEZ_SHADER_LIT_SPECULAR,
	NEZ_SHADER_TEXTURED,
	NEZ_SHADER_TEXTURED_ONE_MINUS_SRC_ALPHA,
} ShaderTypes;

enum AletterationTextureNumber {
	TEXTURE_BOX = 0,
	TEXTURE_LETTERS,
	TEXTURE_NUMBERS,
	TEXTURE_SCORES,
	TEXTURE_TABLE,
	TEXTURE_GLOW,
	TEXTURE_RAYS,
	TEXTURE_LOAD_COUNT
};

static NSMutableArray *gTextureList = nil;
static NSMutableArray *gVertexArrayList = nil;
static NSMutableArray *gLetterBlockList = nil;
static NSMutableArray *gLetterStackList = nil;
static NSMutableArray *gDisplayLineList = nil;
static NSMutableArray *gHighlightRectList = nil;

static NezAletterationScoreboard *gScoredboard;

static NezAletterationBackground *gBackground;
static NezAletterationBox *gBox;
static NezAletterationLid *gLid;
static NezAletterationRaysRectangle *gRays;

static NezCamera *gCamera;

static float gLoadingProgress = 0.0f;

static BOOL gSoundEnabled, gMusicEnabled;
static float gSoundVolume, gMusicVolume;

static NezAVAudioPlayer *backgroundMusicPlayer = nil;
static NezAVAudioPlayer *endMusicPlayer = nil;

static NezOpenALPlayer *gSoundPlayer = nil;

static NezAletterationPrefsObject *gAletterationPreferences = nil;

static NezAletterationLetterBlock *gSelectedBlock = nil;

static NezAletterationLetterCounter gLetterCounter;

@implementation NezAletterationGameState

+(void)initialize {
	NezAletterationPrefsObject *preferences = [NezAletterationGameState getPreferences];
	for (int i=0; i<26; i++) {
		gLetterCounter.count[i] = [NezAletterationGameState getBlockCountForIndex:i];
		ALETTERATION_LETTER_COUNT += gLetterCounter.count[i];
	}
	gCamera = [[NezCamera alloc] initWithEye:GLKVector3Make(0.0f, 0.0f, 0.0f) Target:GLKVector3Make(0.0f, 0.0f, 0.0f) UpVector:GLKVector3Make(0.0f, 0.0f, 1.0f)];
	
	if (preferences.stateObject == nil) {
		preferences.stateObject = [NezAletterationGameStateObject stateObject];
	}
}

+(float)getLongestScreenDimension {
    UIScreen *screen = [UIScreen mainScreen];
    CGRect fullScreenRect = screen.bounds; //implicitly in Portrait orientation.
	if (fullScreenRect.size.height > fullScreenRect.size.width) {
		return fullScreenRect.size.height;
	} else {
		return fullScreenRect.size.width;
	}
}

+(const int*)getLetterBag {
	return ALETTERATION_LETTER_BAG;
}

+(NSArray*)getVertexArrayList {
	if (gInitialStateSet) {
		return gVertexArrayList;
	} else {
		return nil;
	}
}

+(float)getLoadingProgress {
	return gLoadingProgress;
}

+(void)loadInitialState:(EAGLContext*)context {
	if (context == nil) {
		return;
	}
    static BOOL initialized = NO;
    if(!initialized) {
        initialized = YES;
		[EAGLContext setCurrentContext:context];
		
		[NezAletterationGameState loadTextures];
		gLoadingProgress = 1.0/3.0;
		[NezAletterationGameState loadModels];
		gLoadingProgress = 2.0/3.0;
		[NezAletterationGameState attachVboToVertexArrayList];
		gLoadingProgress = 3.0/3.0;
		
		gInitialStateSet = YES;
	}
}

#pragma mark -  Sound Functions

+(void)loadSounds {
	gSoundEnabled = gAletterationPreferences.soundEnabled;
	gSoundVolume  = gAletterationPreferences.soundVolume;
//	gSoundPlayer = [[NezOpenALPlayer alloc] initWithEnabled:gSoundEnabled Volume:gSoundVolume];
}

+(void)playSound:(unsigned int)sound withPitch:(float)pitch {
//	[gSoundPlayer playSound:sound withPitch:pitch];
}

+(NezOpenALSoundLoader*)getLoadedSounds {
	return gSoundPlayer.loadedSounds;
}

#pragma mark -  Music Loading

+(void)loadMusicWithDoneBlock:(NezGCDBlock)doneBlock {
	[NezGCD runHighPriorityWithWorkBlock:^{
		gMusicEnabled = gAletterationPreferences.musicEnabled;
		gMusicVolume  = gAletterationPreferences.musicVolume;
		
		backgroundMusicPlayer = [[NezAVAudioPlayer alloc] initWithSongName:@"bgMusic" NumberOfLoops:-1 Enabled:gMusicEnabled Volume:gMusicVolume];
		endMusicPlayer = [[NezAVAudioPlayer alloc] initWithSongName:@"endMusic" NumberOfLoops:0 Enabled:gMusicEnabled Volume:gMusicVolume];
	} DoneBlock:doneBlock];
}

#pragma mark -  Texture Loading

+(GLKTextureInfo*)loadTexture:(NSString*)textureDirectory bindToUnit:(GLuint)textureUnit {
    NSError *error = nil;   // stores the error message if we mess up
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                        forKey:GLKTextureLoaderGenerateMipmaps];
    
    NSString *bundlepath = [[NSBundle mainBundle] pathForResource:@"00" ofType:@"png" inDirectory:[NSString stringWithFormat:@"Textures/%@", textureDirectory]];
    
	glActiveTexture(GL_TEXTURE0+textureUnit); // to specify texture unit
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:bundlepath options:options error:&error];
	glBindTexture(textureInfo.target, textureInfo.name);
	
	return textureInfo;
}

+(void)loadTextures {
	gTextureList = [NSMutableArray arrayWithCapacity:TEXTURE_LOAD_COUNT];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"BoxTexture"     bindToUnit:TEXTURE_BOX]];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"LettersTexture" bindToUnit:TEXTURE_LETTERS]];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"NumbersTexture" bindToUnit:TEXTURE_NUMBERS]];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"ScoresTexture"  bindToUnit:TEXTURE_SCORES]];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"WoodTexture"    bindToUnit:TEXTURE_TABLE]];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"GlowTexture"    bindToUnit:TEXTURE_GLOW]];
	[gTextureList addObject:[NezAletterationGameState loadTexture:@"RaysTexture"    bindToUnit:TEXTURE_RAYS]];
}

+(void)setCamera:(NezCamera*)camera {
	gCamera = camera;
}

+(NezCamera*)getCamera {
	return gCamera;
}

+(NezAletterationBox*)getBox {
	return gBox;
}

+(NezAletterationLid*)getLid {
	return gLid;
}

+(NSArray*)getLetterStacks {
	return gLetterStackList;
}

+(NezAletterationLetterStack*)getLetterStackForLetter:(char)letter {
	return [gLetterStackList objectAtIndex:letter-'a'];
}

+(NSArray*)getLetterBlockList {
	return gLetterBlockList;
}

+(NSArray*)getDisplayLineList {
	return gDisplayLineList;
}

+(NezAletterationDisplayLine*)getDisplayIntersectingRay:(NezRay*)ray {
	for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
		if ([displayLine intersect:ray]) {
			return displayLine;
		}
	}
	return nil;
}

+(NezAletterationScoreboard*)getScoreboard {
	return gScoredboard;
}

#pragma mark -  Model Loading

+(void)loadModels {
	gVertexArrayList = [[NSMutableArray alloc] initWithCapacity:16];

	[NezAletterationGameState loadBackground];
	[NezAletterationGameState loadRays];
	[NezAletterationGameState loadDisplayLines];
	[NezAletterationGameState loadLetterStacks];
	[NezAletterationGameState loadLetterBlocks];
	[NezAletterationGameState loadBox];
	[NezAletterationGameState loadHighlightRects];
}

+(void)loadLetterBlocks {
	GLKVector4 blockColor = [NezAletterationGameState getBlockColor];
	gLetterBlockList = [[NSMutableArray alloc] initWithCapacity:[NezAletterationGameState getTotalLetterCount]];
	NezVertexArray *letterBlockVertexArray = nil;
	for (int letter='a'; letter<='z'; letter++) {
		int letterCount = [NezAletterationGameState getBlockCountForLetter:letter];
		for (int i=0; i<letterCount; i++) {
			if (letterBlockVertexArray == nil || [letterBlockVertexArray canHoldMorePaletteEntries:1] == NO) {
				letterBlockVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:150 indexIncrement:150 TextureUnit:TEXTURE_LETTERS ProgramType:NEZ_SHADER_LIT_SPECULAR];
				[gVertexArrayList addObject:letterBlockVertexArray];
			}
			[gLetterBlockList addObject:[[NezAletterationLetterBlock alloc] initWithVertexArray:letterBlockVertexArray letter:letter modelMatrix:GLKMatrix4Identity color:blockColor]];
		}
	}
}

+(void)loadLetterStacks {
	gLetterStackList = [[NSMutableArray alloc] initWithCapacity:26];
	NezVertexArray *stackVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:50 indexIncrement:50 TextureUnit:TEXTURE_NUMBERS ProgramType:NEZ_SHADER_TEXTURED_ONE_MINUS_SRC_ALPHA];
	for (int letter='a'; letter<='z'; letter++) {
		NezAletterationLetterStack *stack = [[NezAletterationLetterStack alloc] initWithVertexArray:stackVertexArray];
		stack.letter = letter;
		[gLetterStackList addObject:stack];
	}
	[gVertexArrayList addObject:stackVertexArray];
}

+(void)loadDisplayLines {
	gDisplayLineList = [[NSMutableArray alloc] initWithCapacity:NEZ_ALETTERATION_LINE_COUNT];
	NezVertexArray *linesVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:16 indexIncrement:16 TextureUnit:TEXTURE_LETTERS ProgramType:NEZ_SHADER_COLORED_ONE_MINUS_SRC_ALPHA];
	GLKVector4 color = [NezAletterationGameState getBlockColor];
	color.a = 0.5;
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	GLKMatrix4 sizeMatrix = GLKMatrix4MakeScale([NezAletterationGameState getLineWidth], size.y, 1.0f);
	for (int lineIndex=0; lineIndex<NEZ_ALETTERATION_LINE_COUNT; lineIndex++) {
		GLKMatrix4 mat = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(0, [NezAletterationGameState getYForLine:lineIndex], 0.0f), sizeMatrix);
		NezAletterationDisplayLine *line = [[NezAletterationDisplayLine alloc] initWithVertexArray:linesVertexArray modelMatrix:mat color:color lineIndex:lineIndex];
		[gDisplayLineList addObject:line];
	}
	[gVertexArrayList addObject:linesVertexArray];
	
	GLKVector3 pos = GLKVector3Make(sizeMatrix.m00/2.0+size.x, [NezAletterationGameState getYForLine:NEZ_ALETTERATION_LINE_COUNT-1], size.z/2.0);
	gScoredboard = [NezAletterationScoreboard scoreboardWithStartingPosition:pos andLineSpace:[NezAletterationGameState getLineSpace]];
}

+(float)getYForLine:(int)lineIndex {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	return (lineIndex*(size.y+[NezAletterationGameState getLineSpace]))-(size.y*0.76f);
}

+(float)getLineSpace {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	return (size.y*0.033);
}

+(float)getLineWidth {
	GLKVector3 size = [NezAletterationLetterBlock getBlockSize];
	float lineWidth = [NezAletterationGameState getLongestScreenDimension]/32.0;
	if (lineWidth < 15) {
		lineWidth = 15;
	}
	if (lineWidth > 18) {
		lineWidth = 18;
	}
	return size.x*lineWidth;
}

+(GLKMatrix4)getOriginalBoxMatrix {
	return GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 0.0, 0.0, 1.0);
}

+(void)loadBox {
	GLKVector4 blockColor = [NezAletterationGameState getBlockColor];
	
	NezVertexArray *boxVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:100 indexIncrement:100 TextureUnit:TEXTURE_BOX ProgramType:NEZ_SHADER_LIT_SPECULAR];
	
	GLKMatrix4 modelMatrix = [NezAletterationGameState getOriginalBoxMatrix];
	
	gBox = [[NezAletterationBox alloc] initWithVertexArray:boxVertexArray modelMatrix:modelMatrix color:blockColor];
	gLid = [[NezAletterationLid alloc] initWithVertexArray:boxVertexArray modelMatrix:modelMatrix color:blockColor];
	
	[gBox attachLid:gLid];
	[gBox addLetterBlockList:gLetterBlockList];
	
	[gVertexArrayList addObject:boxVertexArray];
}

+(void)loadBackground {
	NezVertexArray *backgroundVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:100 indexIncrement:100 TextureUnit:TEXTURE_RAYS ProgramType:NEZ_SHADER_COLORED];
	backgroundVertexArray.depthTest = NO;
	
	GLKMatrix4 modelMatrix = GLKMatrix4Identity;
	
	gBackground = [[NezAletterationBackground alloc] initWithVertexArray:backgroundVertexArray modelMatrix:modelMatrix color:GLKVector4Make(0.0, 1.0, 0.0, 1.0)];
	
	[gVertexArrayList addObject:backgroundVertexArray];
}

+(void)loadRays {
	NezVertexArray *raysVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:10 indexIncrement:10 TextureUnit:TEXTURE_RAYS ProgramType:NEZ_SHADER_TEXTURED_ONE_MINUS_SRC_ALPHA];
	raysVertexArray.depthTest = NO;
	
	GLKMatrix4 translation = GLKMatrix4MakeTranslation(0.0, 20.0, 27.5);
	GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90), 1.0, 0.0, 0.0);
	GLKMatrix4 scale = GLKMatrix4MakeScale(90.0, 90.0, 0.0);
	
	GLKMatrix4 modelMatrix;
	
	modelMatrix = translation;
	modelMatrix = GLKMatrix4Multiply(modelMatrix, rotation);
	modelMatrix = GLKMatrix4Multiply(modelMatrix, scale);
	
	gRays = [[NezAletterationRaysRectangle alloc] initWithVertexArray:raysVertexArray modelMatrix:modelMatrix color:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];
	
	[gVertexArrayList addObject:raysVertexArray];
}

+(void)loadHighlightRects {
	int n=6;//2+[NezAletterationGameState getTotalLetterCount]/8;
	gHighlightRectList = [NSMutableArray arrayWithCapacity:n];
	
	NezVertexArray *highlightVertexArray = [[NezVertexArray alloc] initWithVertexIncrement:20 indexIncrement:20 TextureUnit:TEXTURE_GLOW ProgramType:NEZ_SHADER_TEXTURED_ONE_MINUS_SRC_ALPHA];
	for (int i=0; i<n; i++) {
		NezStrectableRectangle2D *highlightRect = [[NezStrectableRectangle2D alloc] initWithVertexArray:highlightVertexArray modelMatrix:GLKMatrix4Identity color:GLKVector4Make(1.0, 1.0, 1.0, 1.0)];
		[gHighlightRectList addObject:highlightRect];
		
	}
	int i=0;
	for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
		displayLine.highlightRect = [gHighlightRectList objectAtIndex:i++];
	}
	[gVertexArrayList addObject:highlightVertexArray];
}

#pragma mark -  VBO Functions

+(void)attachVboToVertexArrayList {
	for (NezVertexArray *vertexArray in gVertexArrayList) {
		[NezAletterationGameState attachVboToVertexArray:vertexArray];
	}
}

+(void)attachVboToVertexArray:(NezVertexArray*)vertexArray {
	glGenVertexArraysOES(1, vertexArray.vertexArrayObjectPtr);
	glBindVertexArrayOES(vertexArray.vertexArrayObject);
	
	glGenBuffers(1, vertexArray.vertexArrayBufferPtr);
	glBindBuffer(GL_ARRAY_BUFFER, vertexArray.vertexArrayBuffer);
	glBufferData(GL_ARRAY_BUFFER, sizeof(Vertex)*vertexArray.vertexCount, vertexArray.vertexList, GL_STATIC_DRAW);
	
	glGenBuffers(1, vertexArray.vertexElementBufferPtr);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vertexArray.vertexElementBuffer);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(unsigned short)*vertexArray.indexCount, vertexArray.indexList, GL_STATIC_DRAW);
	
	int stride = sizeof(Vertex);
	
	switch (vertexArray.programType) {
		case NEZ_SHADER_COLORED:
			vertexArray.program = [[NezGLSLProgram alloc] initWithProgramName:@"Colored"];
			break;
		case NEZ_SHADER_COLORED_ONE_MINUS_SRC_ALPHA:
			vertexArray.program = [[NezGLSLProgram alloc] initWithProgramName:@"ColoredOneMinusSrcAlpha"];
			break;
		case NEZ_SHADER_LIT_SPECULAR:
			vertexArray.program = [[NezGLSLProgram alloc] initWithProgramName:@"LitWithSpecularHighlightTextured"];
			break;
		case NEZ_SHADER_TEXTURED:
			vertexArray.program = [[NezGLSLProgram alloc] initWithProgramName:@"Textured"];
			break;
		case NEZ_SHADER_TEXTURED_ONE_MINUS_SRC_ALPHA:
			vertexArray.program = [[NezGLSLProgram alloc] initWithProgramName:@"TexturedOneMinusSrcAlpha"];
			break;
		default:
			vertexArray.program = [[NezGLSLProgram alloc] initWithProgramName:@"Colored"];
			break;
	}
    glUseProgram(vertexArray.program->program);
    
	if (vertexArray.program->a_position != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(vertexArray.program->a_position);
		glVertexAttribPointer(vertexArray.program->a_position, 3, GL_FLOAT, GL_FALSE, stride, [NezVertexArray vertexOffsetPos]);
	}
	if (vertexArray.program->a_normal != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(vertexArray.program->a_normal);
		glVertexAttribPointer(vertexArray.program->a_normal, 3, GL_FLOAT, GL_FALSE, stride, [NezVertexArray vertexOffsetNormal]);
	}
	if (vertexArray.program->a_uv != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(vertexArray.program->a_uv);
		glVertexAttribPointer(vertexArray.program->a_uv, 2, GL_FLOAT, GL_FALSE, stride, [NezVertexArray vertexOffsetUV]);
	}
	if (vertexArray.program->a_indexArray != NEZ_GLSL_ITEM_NOT_SET) {
		glEnableVertexAttribArray(vertexArray.program->a_indexArray);
		glVertexAttribPointer(vertexArray.program->a_indexArray, NEZ_GLSL_MAX_BLEND_COUNT, GL_UNSIGNED_BYTE, GL_FALSE, stride, [NezVertexArray vertexOffsetIndexArray]);
	}
	glBindVertexArrayOES(0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glUseProgram(0);
}

#pragma mark -  Cleanup Memory Functions

+(void)cleanup {
	[NezAletterationGameState deleteVertexArrayList:gVertexArrayList];
	[NezAletterationGameState deleteTextures];
	
	[gLetterBlockList removeAllObjects];
	[gDisplayLineList removeAllObjects];
}

+(void)deleteVertexArrayList:(NSMutableArray*)vertexArrayList {
	int vertexArrayCount = vertexArrayList.count;
	if (vertexArrayCount > 0) {
		int bufferCount = vertexArrayCount*2;
		int vaCount = vertexArrayCount;
		GLuint *bufferIdArray = (GLuint*)malloc(sizeof(GLuint)*vertexArrayCount*2);
		GLuint *vaIdArray = (GLuint*)malloc(sizeof(GLuint)*vertexArrayCount);
		int bufferIndex = 0;
		int vaIndex = 0;
		for (NezVertexArray *vertexArray in vertexArrayList) {
			bufferIdArray[bufferIndex++] = vertexArray.vertexElementBuffer;
			bufferIdArray[bufferIndex++] = vertexArray.vertexArrayBuffer;
			vaIdArray[vaIndex++] = vertexArray.vertexArrayObject;
		}
		glDeleteBuffers(bufferCount, bufferIdArray);
		glDeleteVertexArraysOES(vaCount, vaIdArray);
		
		free(bufferIdArray);
		free(vaIdArray);
	}
}

+(void)deleteTextures {
	GLuint textureNameList[TEXTURE_LOAD_COUNT];
	int i = 0;
	for (GLKTextureInfo *texInfo in gTextureList) {
		textureNameList[i] = texInfo.name;
	}
	glDeleteTextures(i, textureNameList);
	[gTextureList removeAllObjects];
}

#pragma mark -  Aletteration Game Functions

+(void)reset {
	for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
		[displayLine reset];
	}
	[gAletterationPreferences.stateObject reset];
}

+(void)setFirstTurn {
	[gAletterationPreferences.stateObject reset];
}

+(void)startGame:(NezAletterationGameStateObject*)stateObject {
	if (stateObject == nil || stateObject.turnStack.count == 0) {
		[NezAletterationGameState setFirstTurn];
	} else {
		gAletterationPreferences.stateObject = stateObject;
		int turnIndex = 0;
		for (NezAletterationGameStateTurn *turn in stateObject.turnStack) {
			for (NezAletterationGameStateRetiredWord *retiredWordState in turn.retiredWordList) {
				NezAletterationDisplayLine *displayLine = [gDisplayLineList objectAtIndex:retiredWordState.lineIndex];
				displayLine.currentWordIndex = retiredWordState.range.location;
				NSLog(@"%s", displayLine.currentWord);
				NezAletterationRetiredWord *retiredWord = [displayLine retireHighlightedWord];
				[gScoredboard addRetiredWord:retiredWord isAnimated:NO];
			}
			if (turn.lineIndex == -1) {
				break;
			}
			char letter = stateObject.letterList[turnIndex++];
			NezAletterationLetterBlock *letterBlock = [NezAletterationGameState popLetterBlock:letter isAnimated:NO];
			NezAletterationDisplayLine *displayLine = [gDisplayLineList objectAtIndex:turn.lineIndex];
			
			[letterBlock setMidPoint:[displayLine getNextLetterBlockPosition]];
			[displayLine addLetterBlock:letterBlock];
		}
		for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
			NezAletterationWordState *wordState = [stateObject getTopWordStateForLineIndex:displayLine.lineIndex];
			displayLine.currentWordIndex = wordState.index;
			displayLine.isWord = (wordState.state == NEZ_DIC_INPUT_ISWORD || wordState.state == NEZ_DIC_INPUT_ISBOTH);
			[displayLine setLetterBlockColors:NO];
		}
	}
}

+(void)endTurn:(int)lineIndex withBlock:(NezGCDBlock)endTurnBlock {
	NezAletterationDisplayLine *displayLine = [gDisplayLineList objectAtIndex:lineIndex];
	[displayLine addLetterBlock:gSelectedBlock];
	[gAletterationPreferences.stateObject endTurn:lineIndex];
	gSelectedBlock = nil;
	[NezGCD runLowPriorityWithWorkBlock:^{
		[NezAletterationGameState checkAllLines];
	} DoneBlock:^{
		//set block colors
		for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
			[displayLine setLetterBlockColors:YES];
		}

		//finally call endBlock
		if (endTurnBlock != nil) {
			endTurnBlock();
		}
	}];
}

+(void)checkLine:(NezAletterationDisplayLine*)displayLine {
	if (displayLine.count > 0) {
		NezAletterationLetterCounter letterCounter = gLetterCounter;
		if (gSelectedBlock) {
			letterCounter.count[gSelectedBlock.letter-'a']++;
		}
		NezAletterationGameStateObject *stateObject = gAletterationPreferences.stateObject;
		char *currentWord = displayLine.currentWord;
		NezAletterationDictionaryInputType state = [NezAletterationSQLiteDictionary getTypeWithInput:currentWord LetterCounts:letterCounter];
		NezAletterationWordState *wordState = [stateObject getTopWordStateForLineIndex:displayLine.lineIndex];
		wordState.state = state;
		if (wordState.state == NEZ_DIC_INPUT_ISWORD || wordState.state == NEZ_DIC_INPUT_ISPREFIX || wordState.state == NEZ_DIC_INPUT_ISBOTH) {
			wordState.index = displayLine.currentWordIndex;
			wordState.length = displayLine.currentWordLength;
		} else {
			wordState.state = NEZ_DIC_INPUT_ISNOTHING;
			wordState.index = displayLine.count;
			wordState.length = 0;
			for (int i=displayLine.currentWordIndex+1; i<displayLine.count; i++) {
				currentWord++;
				state = [NezAletterationSQLiteDictionary getTypeWithInput:currentWord LetterCounts:letterCounter];
				if (state == NEZ_DIC_INPUT_ISWORD || state == NEZ_DIC_INPUT_ISPREFIX || state == NEZ_DIC_INPUT_ISBOTH) {
					wordState.state = state;
					wordState.index = i;
					wordState.length = displayLine.count-i;
					break;
				}
			}
		}
		displayLine.currentWordIndex = wordState.index;
		displayLine.isWord = (wordState.state == NEZ_DIC_INPUT_ISWORD || wordState.state == NEZ_DIC_INPUT_ISBOTH);
	}
}

+(void)checkAllLines {
	for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
		[NezAletterationGameState checkLine:displayLine];
	}
}

+(NezAletterationLetterBlock*)startNextTurn:(BOOL)animated {
	NezAletterationGameStateObject *stateObject = gAletterationPreferences.stateObject;
	if ([NezAletterationGameState getTotalLetterCount] == stateObject.turnStack.count) {
		return nil;
	}
	NezAletterationGameStateTurn *currentTurn = stateObject.currentTurn;
	if (currentTurn != nil) {
		if (currentTurn.lineIndex == -1) {
			int turnIndex = stateObject.turnStack.count-1;
			return [NezAletterationGameState popLetterBlock:stateObject.letterList[turnIndex] isAnimated:animated];
		}
	}
	[stateObject pushNextTurn];
	int turnIndex = stateObject.turnStack.count-1;
	return [NezAletterationGameState popLetterBlock:stateObject.letterList[turnIndex] isAnimated:animated];
}

+(NezAletterationLetterBlock*)popLetterBlock:(char)letter isAnimated:(BOOL)animated {
	NezAletterationLetterStack *stack = [NezAletterationGameState getLetterStackForLetter:letter];
	gSelectedBlock = [stack popLetterBlock:animated];
	gLetterCounter.count[letter-'a'] = stack.count;
	return gSelectedBlock;
}

+(void)retireWordForDisplayLine:(NezAletterationDisplayLine*)displayLine {
	if (displayLine.isWord) {
		NSRange wordRange = { displayLine.currentWordIndex, displayLine.currentWordLength };
		NezAletterationRetiredWord *retiredWord = [displayLine retireHighlightedWord];

		[NezGCD runLowPriorityWithWorkBlock:^{
			NezAletterationGameStateObject *stateObject = gAletterationPreferences.stateObject;
			[stateObject removeWordStateInRange:wordRange forLineIndex:displayLine.lineIndex];
			NSMutableArray *wordStateStack = [stateObject getWordStateStackForLineIndex:displayLine.lineIndex];
			NezAletterationWordState *useState = nil;
			for (NezAletterationWordState *wordState in [wordStateStack reverseObjectEnumerator]) {
				if (wordState.state == NEZ_DIC_INPUT_ISNOTHING) {
					useState = wordState;
					break;
				}
			}
			if (useState != nil) {
				displayLine.currentWordIndex = useState.index;
			} else {
				displayLine.currentWordIndex = 0;
			}
			[NezAletterationGameState checkLine:displayLine];
		} DoneBlock:^{
			[displayLine setLetterBlockColors:YES];
			[gScoredboard addRetiredWord:retiredWord isAnimated:YES];
		}];
		
	}
}

+(int)getStackCurrentLetterCount {
	int count = 0;
	for(NezAletterationLetterStack *stack in gLetterStackList) {
		count += stack.count-stack.deferredCount;
	}
	return count;
}

#pragma mark -  Preference get/set Functions

+(float)getBrightnessWithColor:(GLKVector4)color {
	return [NezAletterationGameState getBrightnessWithRed:color.r Green:color.g Blue:color.b];
}

+(float)getBrightnessWithRed:(float)r Green:(float)g Blue:(float)b {
	return ((r * 299.0) + (g * 587.0) + (b * 114.0)) / 1000.0;
}

+(GLKVector4)getBlockColor {
	return gAletterationPreferences.blockColor;
}

+(void)setBlockColor:(GLKVector4)color {
	for (NezAletterationLetterBlock *lb in gLetterBlockList) {
		lb.color1 = color;
		[lb setUV:[lb getUV]];
	}
	color.a = 0.5;
	for (NezAletterationDisplayLine *displayLine in gDisplayLineList) {
		displayLine.color1 = color;
	}
}

+(NezAletterationPrefsObject*)getPreferences {
	if (gAletterationPreferences == nil) {
		gAletterationPreferences = [NezAletterationPrefs getPreferences];
	}
	return gAletterationPreferences;
}

+(void)setPreferences:(NezAletterationPrefsObject*)prefs {
	gAletterationPreferences = prefs;
	[NezAletterationPrefs setPreferences:prefs];
}

+(void)savePreferences {
	[NezAletterationPrefs setPreferences:gAletterationPreferences];
}

+(int)getTotalLetterCount {
	return ALETTERATION_LETTER_COUNT;
}

+(int)getBlockCountForLetter:(char)letter {
	return ALETTERATION_LETTER_BAG[letter-'a'];
}

+(int)getBlockCountForIndex:(int)index {
	return ALETTERATION_LETTER_BAG[index];
}

+(void)setAletterationLogoFrame:(CGRect)frame {
	ALETTERATION_LOGO_FRAME = frame;
}

+(CGRect)getAletterationLogoFrame {
	return ALETTERATION_LOGO_FRAME;
}

+(void)setBufferSubData:(NezVertexArray*)vertexArray Data:(void*)data Offset:(unsigned int)offset Size:(unsigned int)size {
	glBindBuffer(GL_ARRAY_BUFFER, vertexArray.vertexArrayBuffer);
	glBufferSubData(GL_ARRAY_BUFFER, offset, size, data);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
}

@end

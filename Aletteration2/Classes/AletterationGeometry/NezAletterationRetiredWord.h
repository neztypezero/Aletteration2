//
//  NezAletterationRetiredWord.h
//  Aletteration2
//
//  Created by David Nesbitt on 2012-11-15.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface NezAletterationRetiredWord : NSObject {
	GLKMatrix4 _modelMatrix;
}

@property(nonatomic, strong) NSString *string;
@property (nonatomic, getter=getModelMaxtrix, setter=setModelMaxtrix:) GLKMatrix4 modelMatrix;
@property(nonatomic, readonly) NSArray *letterBlockList;

+(id)retiredWordWithLetterBlockList:(NSArray*)letterBlockList;
-(id)initWithLetterBlockList:(NSArray*)letterBlockList;

@end

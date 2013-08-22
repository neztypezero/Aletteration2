//
//  NezCamera.h
//  NezModels3D
//
//  Created by David Nesbitt on 3/7/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "NezRay.h"

@interface NezCamera : NSObject {
	GLKMatrix4 _matrix;
	BOOL _isMatrixInvalid;
	int _viewport[4];
	GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _modelViewProjectionMatrix;
}

-(id)initWithEye:(GLKVector3)eyePos Target:(GLKVector3)lookAtTarget UpVector:(GLKVector3)upVector;

@property(nonatomic, setter = setEye:) GLKVector3 eye;
@property(nonatomic, setter = setTarget:) GLKVector3 target;
@property(nonatomic, setter = setUpVector:) GLKVector3 upVector;

@property(nonatomic, readonly, getter = getMatrix) GLKMatrix4 matrix;
@property(nonatomic, readonly, getter = getProjectionMatrix) GLKMatrix4 projectionMatrix;
@property(nonatomic, readonly, getter = getModelViewProjectionMatrix) GLKMatrix4 modelViewProjectionMatrix;
@property(nonatomic, readonly, getter = getViewport) CGRect viewport;

-(void)setupProjectionMatrix:(CGRect)viewPort;
-(void)setEye:(GLKVector3)eye Target:(GLKVector3)target UpVector:(GLKVector3)upVector;

-(GLKVector2)getScreenCoordinates:(GLKVector3)pos;
-(GLKVector3)getWorldCoordinates:(GLKVector2)screenPos atWorldZ:(float)z;
-(NezRay*)getWorldRay:(GLKVector2)screenPos;

@end

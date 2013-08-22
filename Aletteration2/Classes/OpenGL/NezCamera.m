//
//  NezCamera.m
//  NezModels3D
//
//  Created by David Nesbitt on 3/7/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "NezCamera.h"

@implementation NezCamera

-(id)initWithEye:(GLKVector3)eyePos Target:(GLKVector3)lookAtTarget UpVector:(GLKVector3)upVector {
	if ((self = [super init])) {
		_eye = eyePos;
		_target = lookAtTarget;
		_upVector = upVector;
		_isMatrixInvalid = YES;
	}
	return self;
}

-(void)setEye:(GLKVector3)eye {
	_eye = eye;
	_isMatrixInvalid = YES;
}

-(void)setTarget:(GLKVector3)target {
	_target = target;
	_isMatrixInvalid = YES;
}

-(void)setUpVector:(GLKVector3)upVector {
	_upVector = upVector;
	_isMatrixInvalid = YES;
}

-(GLKMatrix4)getMatrix {
	if (_isMatrixInvalid) {
		_matrix = GLKMatrix4MakeLookAt(_eye.x, _eye.y, _eye.z, _target.x, _target.y, _target.z, _upVector.x, _upVector.y, _upVector.z);
		_isMatrixInvalid = NO;
	}
	return _matrix;
}

-(GLKMatrix4)getProjectionMatrix {
	return _projectionMatrix;
}

-(GLKMatrix4)getModelViewProjectionMatrix {
	return _modelViewProjectionMatrix;
}

-(CGRect)getViewport {
	return CGRectMake(_viewport[0], _viewport[1], _viewport[2], _viewport[3]);
}

-(void)setEye:(GLKVector3)eye Target:(GLKVector3)target UpVector:(GLKVector3)upVector {
	_eye = eye;
	_target = target;
	_upVector = upVector;
	_isMatrixInvalid = YES;
	_modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, self.matrix);
}

-(void)setupProjectionMatrix:(CGRect)viewport {
	_viewport[0] = viewport.origin.x;
	_viewport[1] = viewport.origin.y;
	_viewport[2] = viewport.size.width;
	_viewport[3] = viewport.size.height;
	float aspect = fabsf(viewport.size.width / viewport.size.height);
	_projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
	_modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, self.matrix);
	
}

-(GLKVector2)getScreenCoordinates:(GLKVector3)pos {
	GLKVector4 pos4 = GLKMatrix4MultiplyVector4(_modelViewProjectionMatrix, GLKVector4Make(pos.x, pos.y, pos.z, 1.0));
	GLKVector2 pos2 = GLKVector2Make(pos4.x/pos4.w, pos4.y/pos4.w);
	return GLKVector2Make(_viewport[0] + _viewport[2] * (pos2.x+1.0)/2.0, _viewport[1] + _viewport[3] * (pos2.y+1.0)/2.0);
}

-(GLKVector3)getWorldCoordinates:(GLKVector2)screenPos atWorldZ:(float)z {
	screenPos.y = _viewport[3]-screenPos.y;
	
	GLKVector3 posNear = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 0.0), _matrix, _projectionMatrix, _viewport, NULL);
	GLKVector3 posFar  = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 1.0), _matrix, _projectionMatrix, _viewport, NULL);
	
	float d1 = posNear.z-posFar.z;
	float d2 = posNear.z-z;
	float ratio = d2/d1;
	
	float x = posNear.x-((posNear.x-posFar.x)*ratio);
	float y = posNear.y-((posNear.y-posFar.y)*ratio);
	
	return GLKVector3Make(x, y, z);
}

-(NezRay*)getWorldRay:(GLKVector2)screenPos {
	screenPos.y = _viewport[3]-screenPos.y;
	GLKVector3 posNear = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 0.0), _matrix, _projectionMatrix, _viewport, NULL);
	GLKVector3 posFar  = GLKMathUnproject(GLKVector3Make(screenPos.x, screenPos.y, 1.0), _matrix, _projectionMatrix, _viewport, NULL);
	return [[NezRay alloc] initWithOrigin:posNear andDirection:GLKVector3Subtract(posFar, posNear)];
}

@end

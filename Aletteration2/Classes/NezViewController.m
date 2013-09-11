//
//  NezViewController.m
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//

#import "NezViewController.h"
#import "NezEmbededController.h"
#import "NezSimpleObjLoader.h"
#import "NezGLSLProgram.h"
#import "NezAnimator.h"
#import "NezAnimation.h"
#import "NezAletterationLetterBlock.h"
#import "NezAletterationPrefs.h"
#import "NezAletterationGameState.h"
#import "NezCamera.h"
#import "NezAletterationDisplayLine.h"
#import "NezGCD.h"
#import "NezAppDelegate.h"

@interface NezViewController () {
	NezCamera *_camera;
    GLKMatrix3 _normalMatrix;
	
	GLKVector3 _lightPos;
	GLKVector3 _ambiMaterialColor;
	GLKVector3 _specMaterialColor;
	float _specularPower;
	
	GLKMatrix4 _matrixPalette[NEZ_GLSL_MATRIX_PALETTE_COUNT];
	GLKVector4 _color1Palette[NEZ_GLSL_MATRIX_PALETTE_COUNT];
	GLKVector4 _color2Palette[NEZ_GLSL_MATRIX_PALETTE_COUNT];
	float _mixPalette[NEZ_GLSL_MATRIX_PALETTE_COUNT];
	
	BOOL _isLoading;
	BOOL _depthTest;
}
@property(strong, nonatomic) EAGLContext *context;

-(void)setupGL;
-(void)tearDownGL;

@end

@implementation NezViewController

-(id)initWithCoder:(NSCoder*)aDecoder {
	if ((self =[super initWithCoder:aDecoder])) {
		_lightPos = GLKVector3Make(1.4f, -0.8f, 3.0f);
		_ambiMaterialColor = GLKVector3Make(0.15f, 0.15f, 0.15f);
		_specMaterialColor = GLKVector3Make(0.7f, 0.7f, 0.7f);
		_specularPower = 128.0f;
	}
	_camera = [NezAletterationGameState getCamera];
	[_camera setEye:GLKVector3Make(0.0f, -10.0f, 20.0f) Target:GLKVector3Make(0.0f, 0.0f, 20.0f) UpVector:GLKVector3Make(0.0f, 0.0f, 1.0f)];

	return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
	
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
//Enable anti aliasing if device is fast enough
//	if (iDevice > iPhone4S | iPod Touch 4G) { view.drawableMultisample = GLKViewDrawableMultisample4X; }
	
	NezAletterationGameStateObject *stateObject = [NezAletterationGameState getPreferences].stateObject;
	if (stateObject && stateObject.turn > 0) {
		UIView *view = self.loadingEmbedView;
		view.hidden = YES;
		[view removeFromSuperview];
		if (stateObject.snapshot) {
			self.snapshotImageView.image = stateObject.snapshot;
			self.snapshotImageView.hidden = NO;
		}
		[NezAletterationGameState loadSounds];
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		[self setupGL];
	});
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	self.pauseOnWillResignActive = YES;
	self.resumeOnDidBecomeActive = NO;
	self.paused = YES;
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LoadingEmbedSegue"]) {
		UINavigationController *loadNavController = (UINavigationController*)segue.destinationViewController;
		NezEmbededController *controller = (NezEmbededController*)loadNavController.topViewController;
		controller.parentEmbedView = self.loadingEmbedView;
    } else if ([segue.identifier isEqualToString:@"CommandsSegue"]) {
		self.commandsNavigationController = (UINavigationController*)segue.destinationViewController;
	}
}

-(void)dealloc {
    [self tearDownGL];
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	[NezAnimator removeAllAnimations];
}

//-(void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//
//    if ([self isViewLoaded] && ([[self view] window] == nil)) {
//        self.view = nil;
//        
//        [self tearDownGL];
//        
//        if ([EAGLContext currentContext] == self.context) {
//            [EAGLContext setCurrentContext:nil];
//        }
//        self.context = nil;
//    }
//}

-(void)setPaused:(BOOL)paused {
	[super setPaused:paused];
	NSLog(@"self.paused:%@", self.paused?@"YES":@"NO");
}

-(void)setupGL {
	_isLoading = YES;
	[NezGCD runLowPriorityWithWorkBlock:^{
		[NezAletterationGameState loadInitialState:self.context];
	} DoneBlock:^{
		[EAGLContext setCurrentContext:self.context];
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		glEnable(GL_CULL_FACE);
		glCullFace(GL_BACK);
		_depthTest = YES;
		_isLoading = NO;
		
		if (self.snapshotImageView.hidden == NO) {
			[_camera setupProjectionMatrix:self.view.bounds];
			UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"NezSinglePlayerAletterationController"];
			[self.commandsNavigationController pushViewController:viewController animated:NO];
			[NezAletterationGameState getPreferences].stateObject.snapshot = nil;
			[self performSelector:@selector(hideSnapshot) withObject:nil afterDelay:0.125];
		}
		self.paused = NO;
	}];
}

-(void)hideSnapshot {
	[UIView animateWithDuration:0.5 animations:^{
		self.snapshotImageView.alpha = 0;
	} completion:^(BOOL finished) {
		self.snapshotImageView.hidden = YES;
		[self.snapshotImageView removeFromSuperview];
	}];
}

-(void)setPalettes:(NezVertexArray*)vertexArray {
	for (int i=0, n=vertexArray.paletteCount; i<n; i++) {
		_matrixPalette[i] = vertexArray.paletteArray[i].matrix;
		_color1Palette[i] = vertexArray.paletteArray[i].color1;
		_color2Palette[i] = vertexArray.paletteArray[i].color2;
		_mixPalette[i] = vertexArray.paletteArray[i].mix;
	}
}

-(void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
	[NezAletterationGameState cleanup];
}

#pragma mark - GLKView and GLKViewController delegate methods

-(void)update {
	if (!_isLoading) {
		[_camera setupProjectionMatrix:self.view.bounds];
		_normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(_camera.matrix), NULL);
		[NezAnimator updateWithTimeSinceLastUpdate:self.timeSinceLastUpdate];
	}
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	if (!_isLoading) {
		glClearColor(0.94f, 0.36f, 0.32f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		
		[self drawVertexArraysInList:[NezAletterationGameState getVertexArrayList]];

		glBindVertexArrayOES(0);
	}
}

-(void)drawVertexArraysInList:(NSArray*)vertexArrayList {
	for (NezVertexArray *vertexArray in vertexArrayList) {
		if (_depthTest != vertexArray.depthTest) {
			if (vertexArray.depthTest) {
				glEnable(GL_DEPTH_TEST);
			} else {
				glDisable(GL_DEPTH_TEST);
			}
			_depthTest = vertexArray.depthTest;
		}
		glUseProgram(vertexArray.program->program);
		
		glUniformMatrix4fv(vertexArray.program->u_modelViewProjectionMatrix, 1, 0, _camera.modelViewProjectionMatrix.m);
		if (vertexArray.program->u_texUnit != NEZ_GLSL_ITEM_NOT_SET) {
			glUniform1i(vertexArray.program->u_texUnit, vertexArray.textureUnit);
		}
		if (vertexArray.program->u_normalMatrix != NEZ_GLSL_ITEM_NOT_SET) {
			glUniformMatrix3fv(vertexArray.program->u_normalMatrix, 1, 0, _normalMatrix.m);
			glUniform3fv(vertexArray.program->u_lightPosition, 1, _lightPos.v);
			glUniform3fv(vertexArray.program->u_ambientMaterial, 1, _ambiMaterialColor.v);
			glUniform3fv(vertexArray.program->u_specularMaterial, 1, _specMaterialColor.v);
			glUniform1f(vertexArray.program->u_shininess, _specularPower);
		}
		[self setPalettes:vertexArray];
		glUniformMatrix4fv(vertexArray.program->u_paletteMatrix, vertexArray.paletteCount, GL_FALSE, (float*)_matrixPalette);
		glUniform4fv(vertexArray.program->u_paletteColor1, vertexArray.paletteCount, (float*)_color1Palette);
		glUniform4fv(vertexArray.program->u_paletteColor2, vertexArray.paletteCount, (float*)_color2Palette);
		glUniform1fv(vertexArray.program->u_paletteMix, vertexArray.paletteCount, _mixPalette);
		
		glBindVertexArrayOES(vertexArray.vertexArrayObject);
		glDrawElements(GL_TRIANGLES, vertexArray.indexCount, GL_UNSIGNED_SHORT, 0);
	}
}

@end

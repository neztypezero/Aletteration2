//
//  NezGLSLProgram.h
//  Aletteration2
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAX_NAME_LENGTH 128

#define NEZ_GLSL_ITEM_NOT_SET -1

@interface NezGLSLProgram : NSObject {
@public
	GLuint program;
	GLint a_position;
	GLint a_indexArray;
	GLint a_normal;
	GLint a_uv;
	GLint u_normalMatrix;
	GLint u_texUnit;
	GLint u_paletteColor2;
	GLint u_paletteColor1;
	GLint u_ambientMaterial;
	GLint u_lightPosition;
	GLint u_paletteMatrix;
	GLint u_shininess;
	GLint u_specularMaterial;
	GLint u_paletteMix;
	GLint u_modelViewProjectionMatrix;
}

- (id)initWithProgramName:(NSString*)programName;

@end


//
//  NezGLSLProgram.m
//  Aletteration2
//
//  Created by David Nesbitt on 9/2/10.
//  Copyright 2010 David Nesbitt. All rights reserved.
//

#import "NezGLSLProgram.h"

#define SHADER_FOLDER @"Shaders"

@interface NezGLSLProgram (PrivateMethods)
-(BOOL)loadShader:(NSString*)shaderName;
-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
-(BOOL)linkProgram:(GLuint)prog;
-(BOOL)validateProgram:(GLuint)prog;
@end

@implementation NezGLSLProgram

-(id)initWithProgramName:(NSString*)programName {
	if ((self = [super init])) {
		a_position=NEZ_GLSL_ITEM_NOT_SET;
		a_indexArray=NEZ_GLSL_ITEM_NOT_SET;
		a_normal=NEZ_GLSL_ITEM_NOT_SET;
		a_uv=NEZ_GLSL_ITEM_NOT_SET;
		u_normalMatrix=NEZ_GLSL_ITEM_NOT_SET;
		u_texUnit=NEZ_GLSL_ITEM_NOT_SET;
		u_paletteColor2=NEZ_GLSL_ITEM_NOT_SET;
		u_paletteColor1=NEZ_GLSL_ITEM_NOT_SET;
		u_ambientMaterial=NEZ_GLSL_ITEM_NOT_SET;
		u_lightPosition=NEZ_GLSL_ITEM_NOT_SET;
		u_paletteMatrix=NEZ_GLSL_ITEM_NOT_SET;
		u_shininess=NEZ_GLSL_ITEM_NOT_SET;
		u_specularMaterial=NEZ_GLSL_ITEM_NOT_SET;
		u_paletteMix=NEZ_GLSL_ITEM_NOT_SET;
		u_modelViewProjectionMatrix=NEZ_GLSL_ITEM_NOT_SET;
		if (![self loadShader:programName]) {
			return nil;
		}
	}
	return self;
}

-(BOOL)loadShader:(NSString*)shaderName {
 	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;

	// Create shader program
	program = glCreateProgram();

	// Create and compile vertex shader
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh" inDirectory:SHADER_FOLDER];
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
		NSLog(@"Failed to compile vertex shader");
		return FALSE;
	}

	// Create and compile fragment shader
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh" inDirectory:SHADER_FOLDER];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
		NSLog(@"Failed to compile fragment shader");
		return FALSE;
	}

	// Attach vertex shader to program
	glAttachShader(program, vertShader);

	// Attach fragment shader to program
	glAttachShader(program, fragShader);

	GLint activeAttributeCount;
	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);

	GLchar itemName[MAX_NAME_LENGTH];
	GLsizei nameLength;
	GLint size;
	GLenum type;

	// Link program
	if (![self linkProgram:program]) {
		NSLog(@"Failed to link program: %d", program);
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if (program) {
			glDeleteProgram(program);
			program = 0;
		}
		return FALSE;
	}

	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);
	for (GLint i=0; i<activeAttributeCount; i++) {
		glGetActiveAttrib(program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);
		if (strncmp("a_position", itemName, nameLength) == 0) { a_position = i; }
		if (strncmp("a_indexArray", itemName, nameLength) == 0) { a_indexArray = i; }
		if (strncmp("a_normal", itemName, nameLength) == 0) { a_normal = i; }
		if (strncmp("a_uv", itemName, nameLength) == 0) { a_uv = i; }
	}

	GLint activeUniformCount;
	glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &activeUniformCount);
	for (GLint i=0; i<activeUniformCount; i++) {
		glGetActiveUniform(program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);
		// Get uniform locations
		if (strncmp("u_normalMatrix", itemName, nameLength) == 0) { u_normalMatrix = glGetUniformLocation(program, itemName); }
		if (strncmp("u_texUnit", itemName, nameLength) == 0) { u_texUnit = glGetUniformLocation(program, itemName); }
		if (strncmp("u_paletteColor2[0]", itemName, nameLength) == 0) { u_paletteColor2 = glGetUniformLocation(program, itemName); }
		if (strncmp("u_paletteColor1[0]", itemName, nameLength) == 0) { u_paletteColor1 = glGetUniformLocation(program, itemName); }
		if (strncmp("u_ambientMaterial", itemName, nameLength) == 0) { u_ambientMaterial = glGetUniformLocation(program, itemName); }
		if (strncmp("u_lightPosition", itemName, nameLength) == 0) { u_lightPosition = glGetUniformLocation(program, itemName); }
		if (strncmp("u_paletteMatrix[0]", itemName, nameLength) == 0) { u_paletteMatrix = glGetUniformLocation(program, itemName); }
		if (strncmp("u_shininess", itemName, nameLength) == 0) { u_shininess = glGetUniformLocation(program, itemName); }
		if (strncmp("u_specularMaterial", itemName, nameLength) == 0) { u_specularMaterial = glGetUniformLocation(program, itemName); }
		if (strncmp("u_paletteMix[0]", itemName, nameLength) == 0) { u_paletteMix = glGetUniformLocation(program, itemName); }
		if (strncmp("u_modelViewProjectionMatrix", itemName, nameLength) == 0) { u_modelViewProjectionMatrix = glGetUniformLocation(program, itemName); }
	}

	// Release vertex and fragment shaders

	if (vertShader) { glDeleteShader(vertShader); }
	if (fragShader) { glDeleteShader(fragShader); }

	return TRUE;
}

-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
	GLint status;

	const GLchar *source;
	NSString *programString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];

	NSDictionary *defineStrings = [NSDictionary dictionaryWithObjectsAndKeys:
		@"4", @"NEZ_GLSL_MAX_BLEND_COUNT",
		@"30", @"NEZ_GLSL_MATRIX_PALETTE_COUNT",
		nil
	];
	for (NSString *key in defineStrings.keyEnumerator) {
		programString = [programString stringByReplacingOccurrencesOfString:key withString:[defineStrings objectForKey:key]];
	}
	source = (GLchar *)[programString UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return FALSE;
	}

	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);

#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif

	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
		glDeleteShader(*shader);
		return FALSE;
	}
	return TRUE;
}

-(BOOL)linkProgram:(GLuint)prog {
	GLint status;

	glLinkProgram(prog);
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0) {
		return FALSE;
	}
	return TRUE;
}

-(BOOL)validateProgram:(GLuint)prog {
	GLint logLength, status;

	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}

	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == 0) {
		return FALSE;
	}
	return TRUE;
}

-(void)dealloc {
	if (program) {
		glDeleteProgram(program);
	}
}

@end


defineHash = Hash.new
ahash = Hash.new
uhash = Hash.new
isStruct = false
foundStructFirstMember = false;
structFirstMember = '';
structName = ""
Dir.chdir("Aletteration2/Resources/Shaders")
Dir.glob('*.[vf]sh') do |fname|
	File.new(fname, "r").each { |line|
		if isStruct then
			if line =~ /.*[}](.*)[;].*/ then
				line = $1.strip();
				if line =~ /(.*)\[.*/ then
					if foundStructFirstMember == false then
						uhash[$1] = ['struct', $1+"[0]"];
						else
						uhash[$1] = ['struct', $1+"[0]."+structFirstMember];
					end
					else
					puts $1;
					uhash[$1] = ['struct', $1];
				end
				isStruct = false;
				elsif foundStructFirstMember == false then
				if line =~ /\s*(\w*)\s*(\w*)\s*[;].*/ then
					structFirstMember = $2;
					foundStructFirstMember = true;
				end
			end
			else
			if line =~ /struct.*/ then
				if line =~ %r{\b(\w*) \{} then
					isStruct = true;
					structFirstMember = '';
					foundStructFirstMember = false;
					end
					end
					if line =~ /attribute.*/ then
						if line =~ %r{\w* (\w*) (\w*)\;} then
							ahash[$2] = [$1, $2];
						end
					end
					if line =~ /uniform.*/ then
						if line =~ /\w* (\w*) (\w*)\;/ then
							uhash[$2] = [$1, $2];
							elsif line =~ /\w* (\w*) (\w*)\[.*\;/ then
							uhash[$2] = [$1, $2+"[0]"];
						end
					end
					end
				}
				end
File.open('../../Classes/Geometry/NezVertexArray.h', 'r').each_line do |line|
	if line =~ /#define NEZ_GLSL_.*/
    	if line =~ %r{\w* (\w*) (\w*)} then
	    	defineHash[$1] = $2;
	    end
    end 
end

File.open('../../Classes/OpenGL/NezGLSLProgram.h', 'w') do |f2|
f2.puts "//"
f2.puts "//  NezGLSLProgram.h"
f2.puts "//  Aletteration2"
f2.puts "//"
f2.puts "//  Created by David Nesbitt on 9/2/10."
f2.puts "//  Copyright 2010 David Nesbitt. All rights reserved."
f2.puts "//\n\n"
f2.puts "#import <OpenGLES/ES2/gl.h>"
f2.puts "#import <OpenGLES/ES2/glext.h>\n\n"
	f2.puts "#define MAX_NAME_LENGTH 128\n\n"
	f2.puts "#define NEZ_GLSL_ITEM_NOT_SET -1\n\n"
f2.puts "@interface NezGLSLProgram : NSObject {"
f2.puts "@public"
f2.puts "	GLuint program;"
ahash.each_key {|key|
    f2.puts "	GLint "+key+";"
}
uhash.each_key {|key|
    f2.puts "	GLint "+key+";"
}
f2.puts "}\n\n"
f2.puts "- (id)initWithProgramName:(NSString*)programName;\n\n"
f2.puts "@end"
f2.puts ""
end

File.open('../../Classes/OpenGL/NezGLSLProgram.m', 'w') do |f2|
f2.puts "//"
f2.puts "//  NezGLSLProgram.m"
f2.puts "//  Aletteration2"
f2.puts "//"
f2.puts "//  Created by David Nesbitt on 9/2/10."
f2.puts "//  Copyright 2010 David Nesbitt. All rights reserved."
f2.puts "//\n\n"
f2.puts "#import \"NezGLSLProgram.h\"\n\n"
f2.puts "#define SHADER_FOLDER @\"Shaders\"\n\n"
f2.puts "@interface NezGLSLProgram (PrivateMethods)"
f2.puts "-(BOOL)loadShader:(NSString*)shaderName;"
f2.puts "-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;"
f2.puts "-(BOOL)linkProgram:(GLuint)prog;"
f2.puts "-(BOOL)validateProgram:(GLuint)prog;"
f2.puts "@end\n\n"
f2.puts "@implementation NezGLSLProgram\n\n"
f2.puts "-(id)initWithProgramName:(NSString*)programName {"
f2.puts "	if ((self = [super init])) {"
	ahash.each_key {|key|
		f2.puts "		"+key+"=NEZ_GLSL_ITEM_NOT_SET;"
	}
	uhash.each_key {|key|
		f2.puts "		"+key+"=NEZ_GLSL_ITEM_NOT_SET;"
	}
f2.puts "		if (![self loadShader:programName]) {"
f2.puts "			return nil;"
f2.puts "		}"
f2.puts "	}"
f2.puts "	return self;"
f2.puts "}\n\n"
f2.puts "-(BOOL)loadShader:(NSString*)shaderName {"
f2.puts " 	GLuint vertShader, fragShader;"
f2.puts "	NSString *vertShaderPathname, *fragShaderPathname;"
f2.puts ""
f2.puts "	// Create shader program"
f2.puts "	program = glCreateProgram();"
f2.puts ''
f2.puts '	// Create and compile vertex shader'
f2.puts '	vertShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"vsh" inDirectory:SHADER_FOLDER];'
f2.puts '	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {'
f2.puts '		NSLog(@"Failed to compile vertex shader");'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts ''
f2.puts '	// Create and compile fragment shader'
f2.puts '	fragShaderPathname = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"fsh" inDirectory:SHADER_FOLDER];'
f2.puts '	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {'
f2.puts '		NSLog(@"Failed to compile fragment shader");'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts ''
f2.puts '	// Attach vertex shader to program'
f2.puts '	glAttachShader(program, vertShader);'
f2.puts ''
f2.puts '	// Attach fragment shader to program'
f2.puts '	glAttachShader(program, fragShader);'
f2.puts ''
f2.puts '	GLint activeAttributeCount;'
f2.puts '	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);'
f2.puts ''
f2.puts '	GLchar itemName[MAX_NAME_LENGTH];'
f2.puts '	GLsizei nameLength;'
f2.puts '	GLint size;'
f2.puts '	GLenum type;'
f2.puts ''
f2.puts '	// Link program'
f2.puts '	if (![self linkProgram:program]) {'
f2.puts '		NSLog(@"Failed to link program: %d", program);'
f2.puts '		if (vertShader) {'
f2.puts '			glDeleteShader(vertShader);'
f2.puts '			vertShader = 0;'
f2.puts '		}'
f2.puts '		if (fragShader) {'
f2.puts '			glDeleteShader(fragShader);'
f2.puts '			fragShader = 0;'
f2.puts '		}'
f2.puts '		if (program) {'
f2.puts '			glDeleteProgram(program);'
f2.puts '			program = 0;'
f2.puts '		}'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts ''
f2.puts '	glGetProgramiv(program, GL_ACTIVE_ATTRIBUTES, &activeAttributeCount);'
f2.puts '	for (GLint i=0; i<activeAttributeCount; i++) {'
f2.puts '		glGetActiveAttrib(program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);'
ahash.each_value {|value|
    f2.puts '		if (strncmp("'+value[1]+'", itemName, nameLength) == 0) { '+value[1]+' = i; }'
}
f2.puts '	}'
f2.puts ''
f2.puts '	GLint activeUniformCount;'
f2.puts '	glGetProgramiv(program, GL_ACTIVE_UNIFORMS, &activeUniformCount);'
f2.puts '	for (GLint i=0; i<activeUniformCount; i++) {'
f2.puts '		glGetActiveUniform(program, i, MAX_NAME_LENGTH, &nameLength, &size, &type, itemName);'
f2.puts '		// Get uniform locations'
uhash.each_key {|key|
    f2.puts '		if (strncmp("'+uhash[key][1]+'", itemName, nameLength) == 0) { '+key+' = glGetUniformLocation(program, itemName); }'
}
f2.puts '	}'
f2.puts ''
f2.puts '	// Release vertex and fragment shaders'
f2.puts ''
f2.puts '	if (vertShader) { glDeleteShader(vertShader); }'
f2.puts '	if (fragShader) { glDeleteShader(fragShader); }'
f2.puts ''
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {'
f2.puts '	GLint status;'
f2.puts ''
f2.puts '	const GLchar *source;'
f2.puts '	NSString *programString = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];'
f2.puts '';
f2.puts '	NSDictionary *defineStrings = [NSDictionary dictionaryWithObjectsAndKeys:';

defineHash.each_key {|key|
	f2.puts '		@"'+defineHash[key]+'", @"'+key+'",';
}

f2.puts '		nil';
f2.puts '	];'
f2.puts '	for (NSString *key in defineStrings.keyEnumerator) {';
f2.puts '		programString = [programString stringByReplacingOccurrencesOfString:key withString:[defineStrings objectForKey:key]];';
f2.puts '	}';
f2.puts '	source = (GLchar *)[programString UTF8String];'
f2.puts '	if (!source) {'
f2.puts '		NSLog(@"Failed to load vertex shader");'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts ''
f2.puts '	*shader = glCreateShader(type);'
f2.puts '	glShaderSource(*shader, 1, &source, NULL);'
f2.puts '	glCompileShader(*shader);'
f2.puts ''
f2.puts '#if defined(DEBUG)'
f2.puts '	GLint logLength;'
f2.puts '	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);'
f2.puts '	if (logLength > 0) {'
f2.puts '		GLchar *log = (GLchar *)malloc(logLength);'
f2.puts '		glGetShaderInfoLog(*shader, logLength, &logLength, log);'
f2.puts '		NSLog(@"Shader compile log:\n%s", log);'
f2.puts '		free(log);'
f2.puts '	}'
f2.puts '#endif'
f2.puts ''
f2.puts '	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);'
f2.puts '	if (status == 0) {'
f2.puts '		glDeleteShader(*shader);'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(BOOL)linkProgram:(GLuint)prog {'
f2.puts '	GLint status;'
f2.puts ''
f2.puts '	glLinkProgram(prog);'
f2.puts '#if defined(DEBUG)'
f2.puts '	GLint logLength;'
f2.puts '	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);'
f2.puts '	if (logLength > 0) {'
f2.puts '		GLchar *log = (GLchar *)malloc(logLength);'
f2.puts '		glGetProgramInfoLog(prog, logLength, &logLength, log);'
f2.puts '		NSLog(@"Program link log:\n%s", log);'
f2.puts '		free(log);'
f2.puts '	}'
f2.puts '#endif'
f2.puts '	glGetProgramiv(prog, GL_LINK_STATUS, &status);'
f2.puts '	if (status == 0) {'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(BOOL)validateProgram:(GLuint)prog {'
f2.puts '	GLint logLength, status;'
f2.puts ''
f2.puts '	glValidateProgram(prog);'
f2.puts '	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);'
f2.puts '	if (logLength > 0) {'
f2.puts '		GLchar *log = (GLchar *)malloc(logLength);'
f2.puts '		glGetProgramInfoLog(prog, logLength, &logLength, log);'
f2.puts '		NSLog(@"Program validate log:\n%s", log);'
f2.puts '		free(log);'
f2.puts '	}'
f2.puts ''
f2.puts '	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);'
f2.puts '	if (status == 0) {'
f2.puts '		return FALSE;'
f2.puts '	}'
f2.puts '	return TRUE;'
f2.puts '}'
f2.puts ''
f2.puts '-(void)dealloc {'
f2.puts '	if (program) {'
f2.puts '		glDeleteProgram(program);'
f2.puts '	}'
f2.puts '}'
f2.puts ''
f2.puts '@end'
f2.puts ''
end

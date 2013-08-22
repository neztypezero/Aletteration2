//
//  LitWithSpecularHighlightTextured.fsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

varying mediump vec4 v_color;

void main(void) {
	gl_FragColor = v_color + (gl_LastFragData[0] * (1.0 - v_color.a));
}
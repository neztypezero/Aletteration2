//
//  LitWithSpecularHighlightTextured.fsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

#extension GL_EXT_shader_framebuffer_fetch : require

uniform sampler2D u_texUnit;

varying mediump vec2 v_uv;
varying mediump float v_alpha;

void main(void) {
	mediump vec4 textureColor = texture2D(u_texUnit, v_uv);
	mediump float alpha = textureColor.a*v_alpha;
	gl_FragColor = (textureColor * alpha) + (gl_LastFragData[0] * (1.0 - alpha));
}
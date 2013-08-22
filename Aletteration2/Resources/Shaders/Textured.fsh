//
//  LitWithSpecularHighlightTextured.fsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//
uniform sampler2D u_texUnit;

varying mediump vec2 v_uv;

void main(void) {
	gl_FragColor = texture2D(u_texUnit, v_uv);
}
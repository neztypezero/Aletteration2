//
//  LitWithSpecularHighlightTextured.fsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//
uniform sampler2D u_texUnit;

varying mediump vec2 v_uv;
varying mediump vec3 v_diffuse;
varying mediump vec3 v_ambientPlusSpecular;

void main(void) {
	mediump vec4 texturePixel = texture2D(u_texUnit, v_uv);
	mediump vec3 diffuseColor = (((v_diffuse)*(1.0-texturePixel.a))+(texturePixel.rgb*texturePixel.a));
	mediump vec3 color = v_ambientPlusSpecular + diffuseColor;
	gl_FragColor = vec4(color, 1.0);
}


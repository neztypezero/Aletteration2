//
//  LitWithSpecularHighlightTextured.vsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//
const int NUM_PALETTES = NEZ_GLSL_MATRIX_PALETTE_COUNT;

const int c_0 = 0;
const int c_1 = 1;
const int c_2 = 2;
const int c_3 = 3;

attribute vec4 a_position;
attribute vec4 a_indexArray;

uniform mat4 u_modelViewProjectionMatrix;

//Attribute Palettes
uniform mat4 u_paletteMatrix[NUM_PALETTES];
uniform vec4 u_paletteColor1[NUM_PALETTES];
uniform vec4 u_paletteColor2[NUM_PALETTES];
uniform float u_paletteMix[NUM_PALETTES];

varying vec4 v_color;

void main() {
	int idx = int(a_indexArray[c_0]);
	vec4 pos    = u_paletteMatrix[idx] * a_position;
	v_color = mix(u_paletteColor1[idx], u_paletteColor2[idx], u_paletteMix[idx]);
	gl_Position = u_modelViewProjectionMatrix * pos;
}

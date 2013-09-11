//
//  LitWithSpecularHighlightTextured.vsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 David Nesbitt. All rights reserved.
//
const int NUM_PALETTES = NEZ_GLSL_MATRIX_PALETTE_COUNT;

const int c_0 = 0;
const int c_1 = 1;
const int c_2 = 2;
const int c_3 = 3;

attribute vec4 a_position;
attribute vec3 a_normal;
attribute vec2 a_uv;
attribute vec4 a_indexArray;

uniform mat4 u_modelViewProjectionMatrix;
uniform mat3 u_normalMatrix;

//Attribute Palettes
uniform mat4 u_paletteMatrix[NUM_PALETTES];
uniform vec4 u_paletteColor1[NUM_PALETTES];
uniform vec4 u_paletteColor2[NUM_PALETTES];
uniform float u_paletteMix[NUM_PALETTES];

uniform vec3 u_lightPosition;
uniform vec3 u_ambientMaterial;
uniform vec3 u_specularMaterial;
uniform float u_shininess;

varying vec2 v_uv;
varying vec3 v_diffuse;
varying vec3 v_ambientPlusSpecular;

void main() {
	int idx = int(a_indexArray[c_0]);
	vec4 pos = u_paletteMatrix[idx] * a_position;

	vec4 transformedNormal = u_paletteMatrix[idx]*vec4(a_normal, 0.0);
	vec3 N = normalize(transformedNormal.xyz * u_normalMatrix);
	vec3 L = normalize(u_lightPosition);
	vec3 E = vec3(0, 0, 1);
	vec3 H = normalize(L + E); //half plane (half vector)
	
	float df = max(0.0, dot(N, L));
	float sf = max(0.0, dot(N, H));
	sf = pow(sf, u_shininess);

	v_ambientPlusSpecular = u_ambientMaterial + sf * u_specularMaterial;
	v_diffuse = mix(u_paletteColor1[idx], u_paletteColor2[idx], u_paletteMix[idx]).rgb * df;
	v_uv = a_uv;

	gl_Position = u_modelViewProjectionMatrix * pos;
}

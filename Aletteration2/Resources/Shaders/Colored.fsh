//
//  LitWithSpecularHighlightTextured.fsh
//  Aletteration2
//
//  Created by David Nesbitt on 2012-10-19.
//  Copyright (c) 2012 Nezsoft. All rights reserved.
//

varying mediump vec3 v_color;

void main(void) {
	gl_FragColor = vec4(v_color, 1.0);
}
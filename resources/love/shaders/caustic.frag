uniform float counter;

// NOTE: this effect is So Awfully wrong compared to the original game . maybe update later

float lookup(Image tex, float u, float v, float timeU, float timeV) {
	float factorU1 = mod(u - timeU, 65536.);
	float factorV1 = mod(v - timeV, 65536.);
	float factorU0 = (65536. - factorU1);
	float factorV0 = (65536. - factorV1);
	
	float indexU0 = ((mod(u + timeU, 256.)) / 256.);
	float indexU1 = ((mod(u + timeU + 1., 256.)) / 256.);
	float indexV0 = ((mod(v + timeV, 256.)) / 256.);
	float indexV1 = ((mod(v + timeV + 1., 256.)) / 256.);
	
	return (
		Texel(tex, vec2(indexU0, indexV0)).r * (factorU0 / 65536. * factorV0 / 65536.) +
		Texel(tex, vec2(indexU1, indexV0)).r * (factorU1 / 65536. * factorV0 / 65536.) +
		Texel(tex, vec2(indexU0, indexV1)).r * (factorU0 / 65536. * factorV1 / 65536.) +
		Texel(tex, vec2(indexU1, indexV1)).r * (factorU1 / 65536. * factorV1 / 65536.)
	);
}

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	float timeU = (texture_coords.x * 256.);
	float timeV0 = (texture_coords.y * 256.);
	float timeV1 = ((1 - texture_coords.y) * 256.);
	
	float timePool0 = counter;
	float timePool1 = (mod(counter, 65536.) + 1.);
	
	float a1 = lookup(tex, timeU, timeV1, -timePool1 / 6., timePool0 / 8.);
	float a0 = lookup(tex, timeU, timeV0, timePool0 / 10., 0);
	float a = (((a0 + a1) * .5) * 255.);
	
	if (a >= 160.) {
		a = (255. - (a - 160.) * 2.);
	} else if (a >= 128.) {
		a = (5. * (a - 128.));
	} else {
		a = 0.;
	}
	
	return (vec4(vec3(1.), a / 255. / 3.) * color);
}
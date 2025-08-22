uniform float frost;
uniform float glow;

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
	vec4 texColor = Texel(tex, texture_coords);
	
	if (frost > 0.) {
		vec3 frostColor = (vec3(texColor.rgb) * vec3(.6, .6, 1.) + vec3(0., 0., texColor.b));
		texColor.rgb = mix(texColor.rgb, frostColor, frost);
	}
	
	return (vec4(texColor.rgb + texColor.rgb * glow, texColor.a) * color);
}
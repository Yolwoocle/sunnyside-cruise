shader_type canvas_item;

uniform vec4 palette[4]: source_color;
uniform float variant_count = 2.0;

varying float variant_id;
varying flat int palette_i;

void vertex() {
	float sway = INSTANCE_CUSTOM.r;
	float sway_speed = INSTANCE_CUSTOM.g;
	variant_id = INSTANCE_CUSTOM.b;
	palette_i = int(INSTANCE_CUSTOM.a);
	
	// Called for every vertex the material is visible on.
	if (VERTEX.y > 0.0) {
		VERTEX.x += sin(TIME * sway_speed) * sway;
	}
}

void fragment() {
	vec4 color = COLOR;
	
	vec2 shifted_uv = vec2(UV);
	shifted_uv.x = (shifted_uv.x + variant_id) / variant_count;
	
	vec4 pal_color;
	if (palette_i == -1) {
		pal_color = vec4(1.0);
	} else {
		pal_color = palette[palette_i];
	}
	
	COLOR = texture(TEXTURE, shifted_uv) * pal_color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

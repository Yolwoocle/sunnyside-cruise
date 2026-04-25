shader_type canvas_item;

uniform vec4 palette[4]: source_color;

uniform float sway = 10.0;

void vertex() {
	// Called for every vertex the material is visible on.
	if (VERTEX.y > 0.0) {
		VERTEX.x += sin(TIME) * sway;
	}
}

void fragment() {
	// Called for every pixel the material is visible ostencil_moderan
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}

shader_type canvas_item;

uniform vec2 pos;
uniform vec2 viewport_size;
uniform float radius;
uniform vec3 color : source_color;

void fragment() {
	vec2 delta = (UV*viewport_size-pos);
	float dist2 = delta.x * delta.x + delta.y * delta.y;
	COLOR = vec4(color, dist2 < radius*radius ? 0.0 : 1.0);
}
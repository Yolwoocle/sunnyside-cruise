shader_type canvas_item;

uniform vec4 palette[4] : source_color;
uniform vec4 highlight_color: source_color;

uniform float wave_scale = 0.6;
uniform int noise_octaves = 3;
uniform float noise_scale = 10.0;
uniform float noise_frequency = 3.0;
uniform float noise_value = 0.0;
uniform float wave_time_scale = 0.1;

uniform int highlight_noise_octaves = 3;
uniform float highlight_noise_scale = 10.0;
uniform float highlight_noise_frequency = 3.0;
uniform float highlight_noise_value = 0.0;
uniform float highlight_threshold = 0.8;
uniform float highlight_time_scale = 0.2;

// 3D Random function: Returns a random gradient vector for a 3D point
vec3 random(vec3 p) {
	p = vec3( dot(p, vec3(127.1, 311.7, 74.7)),
			  dot(p, vec3(269.5, 183.3, 246.1)),
			  dot(p, vec3(113.5, 271.9, 124.6)) );
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec3 p) {
	// https://godotshaders.com/snippet/2d-noise/
	vec3 i = floor(p);
	vec3 f = fract(p);

	// Quintic interpolation curve
	vec3 u = f * f * (3.0 - 2.0 * f);

	// Calculate gradients for the 8 corners of the cube
	float n000 = dot(random(i + vec3(0, 0, 0)), f - vec3(0, 0, 0));
	float n100 = dot(random(i + vec3(1, 0, 0)), f - vec3(1, 0, 0));
	float n010 = dot(random(i + vec3(0, 1, 0)), f - vec3(0, 1, 0));
	float n110 = dot(random(i + vec3(1, 1, 0)), f - vec3(1, 1, 0));
	float n001 = dot(random(i + vec3(0, 0, 1)), f - vec3(0, 0, 1));
	float n101 = dot(random(i + vec3(1, 0, 1)), f - vec3(1, 0, 1));
	float n011 = dot(random(i + vec3(0, 1, 1)), f - vec3(0, 1, 1));
	float n111 = dot(random(i + vec3(1, 1, 1)), f - vec3(1, 1, 1));

	// Mix the values together (Trilinear interpolation)
	return mix(
		mix(mix(n000, n100, u.x), mix(n010, n110, u.x), u.y),
		mix(mix(n001, n101, u.x), mix(n011, n111, u.x), u.y),
		u.z
	) + 0.5;
}

float fbm(vec3 p, int octaves, float amplitude, float frequency, float value) {
	// https://godotshaders.com/snippet/fractal-brownian-motion-fbm/
	
	for(int i = 0; i < octaves; i++) {
		value += amplitude * noise(frequency * p);
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return value;
}

float map(float value, float fromA, float fromB, float toA, float toB) {
	return toA + ((value - fromA) / (fromB - fromA)) * (toB - toA);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	// Gradient
	float gradient = map(UV.y, 0.0, 1.0, 1.0, 0.0);
	
	// Noise 
	float amplitude = 0.5;
	float wave_noise = fbm(
		vec3(UV * noise_scale, TIME*wave_time_scale),
		noise_octaves, amplitude, noise_frequency, noise_value
	);
	wave_noise = map(wave_noise, 0.0, 1.0, -wave_scale, wave_scale);
	
	// Map to palette
	float noisy_gradient = wave_noise + gradient;
	int palette_index = int(map(noisy_gradient, 0.0, 1.0, 0.0, 4.0));
	palette_index = clamp(palette_index, 0, 3);
	vec4 col = palette[palette_index];
	
	// Highlights
	float highlight_noise = fbm(
		vec3((UV + vec2(2.0)) * highlight_noise_scale, TIME*highlight_time_scale),
		highlight_noise_octaves, 
		amplitude, 
		highlight_noise_frequency, 
		highlight_noise_value
	);
	if (highlight_noise >= highlight_threshold) {
		col = highlight_color;
	}
	
	COLOR = col;
	//COLOR = vec4(map(wave_noise, -wave_scale, wave_scale, 0.0, 1.0));
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}

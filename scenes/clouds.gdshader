shader_type canvas_item;

uniform vec4 color_cloud : source_color = vec4(1.0);
uniform vec4 color_shading : source_color = vec4(vec3(0.8), 1.0);
uniform vec4 color_back : source_color = vec4(vec3(0.7), 1.0);
uniform vec4 color_sky : source_color = vec4(vec3(0.0, 1.0, 0.8), 1.0);

uniform vec2 uv_stretch = vec2(1.0);

uniform int noise_octaves = 1;
uniform float noise_scale = 0.315;
uniform float noise_frequency = 3.0;
uniform float noise_value = 0.0;
//uniform float noise_threshold = 0.05;
uniform float noise_threshold = 0.035;
uniform float noise_y_stretch = 1.0;

uniform float detail_noise_scale = 1.4;
uniform float detail_noise_weight = 0.1;

uniform float worley_scale = 1.35;
uniform float worley_weight = 0.07;

uniform float cloud_shading_threshold = -0.1;
uniform vec3 light_direction = vec3(1.0, 0.0, 1.0);

uniform float scroll_time_scale = 0.015;
uniform float wave_time_scale = 0.007;

uniform float time_offset = 100.0;

// 3D Random function: Returns a random gradient vector for a 3D point
vec2 random2(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

vec3 random3(vec3 uv) {
	return vec3(fract(sin(dot(uv.xyz,
		vec3(12.9898,78.233, 324.123213))) * 43758.5453123));
}

float map(float value, float fromA, float fromB, float toA, float toB) {
	return toA + ((value - fromA) / (fromB - fromA)) * (toB - toA);
}



vec3 perlin_random(vec3 p) {
    p = vec3(
        dot(p, vec3(127.1, 311.7, 74.7)),
        dot(p, vec3(269.5, 183.3, 246.1)),
        dot(p, vec3(113.5, 271.9, 124.6))
    );
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec3 p) {
	// https://godotshaders.com/snippet/2d-noise/
	vec3 i = floor(p);
	vec3 f = fract(p);

	// Quintic interpolation curve
	vec3 u = f * f * (3.0 - 2.0 * f);

	// Calculate gradients for the 8 corners of the cube
	float n000 = dot(perlin_random(i + vec3(0, 0, 0)), f - vec3(0, 0, 0));
	float n100 = dot(perlin_random(i + vec3(1, 0, 0)), f - vec3(1, 0, 0));
	float n010 = dot(perlin_random(i + vec3(0, 1, 0)), f - vec3(0, 1, 0));
	float n110 = dot(perlin_random(i + vec3(1, 1, 0)), f - vec3(1, 1, 0));
	float n001 = dot(perlin_random(i + vec3(0, 0, 1)), f - vec3(0, 0, 1));
	float n101 = dot(perlin_random(i + vec3(1, 0, 1)), f - vec3(1, 0, 1));
	float n011 = dot(perlin_random(i + vec3(0, 1, 1)), f - vec3(0, 1, 1));
	float n111 = dot(perlin_random(i + vec3(1, 1, 1)), f - vec3(1, 1, 1));

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

float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -2; y <= 2; y++) {
		for (int x= -2; x <= 2; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec3 val = random3(vec3(index_uv + neighbor, 0.0));
			vec2 point = val.xy;
			float weight = map(val.z, 0.0, 1.0, 1.0, 2.0);
			
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff) * weight;
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}

float cloud(vec2 str_uv) {
	float amplitude = 0.5;
	float time = TIME + time_offset;
	// A tad inneficient since we're using 3D noise
	float wave_noise = fbm(
		vec3(str_uv.x * noise_scale + time*scroll_time_scale, 0.5, time*wave_time_scale),
		noise_octaves, amplitude, noise_frequency, noise_value
	);

	float detail_noise = fbm(vec3((str_uv.x+100.0) * detail_noise_scale, (str_uv.y+100.0) * detail_noise_scale, time*wave_time_scale),
		noise_octaves, amplitude, noise_frequency, noise_value
	);
	
	float worley_val = worley(str_uv*worley_scale, 10.0, 10.0);
	detail_noise -= sqrt(worley_val)*worley_weight;

	float output;

	float height = wave_noise*0.5 + str_uv.y*noise_y_stretch*0.5 + detail_noise*detail_noise_weight;

	if (height > noise_threshold) {
		float range = map(height, noise_threshold, 1.0, 0.0, 1.0);
		output = range;
	} else {
		output = -1.0;
	}

	return output;
}

void fragment() {
	vec2 str_uv = UV * uv_stretch;
	float cloud1 = cloud(str_uv);
	vec4 col;
	
	if (cloud1 < 0.0) {
		float cloud2 = cloud(str_uv + vec2(400.0, 0.0));
		if (cloud2 < 0.0) {
			col = color_sky;
		} else {
			col = color_back;
		}

	} else {
		float d = 0.05;
		float c_left   = cloud(str_uv + vec2(-d, 0.0));
		float c_right  = cloud(str_uv + vec2( d, 0.0));
		float c_up     = cloud(str_uv + vec2(0.0, -d));
		float c_down   = cloud(str_uv + vec2(0.0,  d));
		
		float dx = (c_right - c_left) / (d * 2.0);
		float dy = (c_down - c_up) / (d * 2.0);
		
		vec3 normal = normalize(vec3(dx, dy, 1.0));
		
		vec3 light_dir = normalize(light_direction);
		float diff = dot(normal, light_dir);
		
		if (diff < cloud_shading_threshold) {
			col = color_shading;
		} else {
			col = color_cloud;
		}
	}
	//col = vec4(vec3(range * 10.0), 1.0);
	COLOR = col;
	// vec4(vec3(color1), 1.0);
}
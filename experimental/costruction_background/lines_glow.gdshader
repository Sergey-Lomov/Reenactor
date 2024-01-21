shader_type canvas_item;

#define MAX_POINTS 8192

uniform vec3 color: source_color;
uniform int points_count;
uniform vec2 points[MAX_POINTS];

float line_segment(in vec2 p, in vec2 a, in vec2 b) {
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return length(pa - h * ba);
}

float getGlow(float dist, float radius, float intensity){
    return pow(radius/dist, intensity);
}

void fragment() {
	float dist = 1.0;
	for (int i = 1; i < points_count; i++) {
		float d = line_segment(UV, points[i], points[i-1]) - 0.001;
		dist = min(d, dist);
	}
	float alpha = 1.0 - smoothstep(0.0, 0.003, dist);
	float glow = getGlow((dist + 0.002), 0.01, 0.95);
	vec3 result = color * (1.0 - smoothstep(0.0, 0.003, dist));
	result += glow * vec3(0.1,0.4,1.0);
	float c_time = (cos(TIME * 2.0) + 1.0) / 2.0 * 0.1;
	result += c_time * (1.0 - smoothstep(0.0, 0.05, dist));
	COLOR = vec4(result, 1.0);
}

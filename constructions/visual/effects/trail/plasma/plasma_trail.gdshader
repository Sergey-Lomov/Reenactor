shader_type canvas_item;

#define MAX_POINTS 		300

uniform vec3 color: source_color;
uniform float width;				//In pixels
uniform vec2 texture_size;			//In pixels

uniform int points_count;
uniform vec2 points[MAX_POINTS];		//Points coords in pixels
uniform float lifetimes[MAX_POINTS];	//Points lifetimes
uniform float disappearing;				//Disappearing duration

//In return vec2 x is full length and y is point position at line
vec2 line_segment(in vec2 p, in vec2 a, in vec2 b) {
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return vec2(length(pa - h * ba), h);
}

void fragment() {
	vec2 xy = vec2(texture_size) * UV;
	vec3 result_color = vec3(0.0);
	float result_alpha = 0.0;
	
	for (int i = 0; i < points_count - 1; i++) {
		vec2 line_params = line_segment(xy, points[i], points[i+1]);
		float dist = line_params.x;
		float l_coord = line_params.y;
		float lifetime = mix(lifetimes[i] - disappearing, lifetimes[i+1] - disappearing, l_coord);
		result_color = max(result_color, color * step(0, dist));
		float act_width = mix(width * 2.0, width, clamp(lifetime, 0.0, 1.0));
		float alpha = smoothstep(act_width, act_width / 4.0, dist) * lifetime;
		result_alpha = max(result_alpha, alpha);
	}
	
	COLOR = vec4(result_color, result_alpha);
}

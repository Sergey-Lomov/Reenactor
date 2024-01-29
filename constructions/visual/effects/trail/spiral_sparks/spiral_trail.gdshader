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
	
	float total_length = 0.0;
	for (int i = 0; i < points_count - 1; i++) {
		total_length += length(points[i] - points[i+1]);
	}
		
	float current_length = 0.0;
	for (int i = 0; i < points_count - 1; i++) {
		vec2 line_params = line_segment(xy, points[i], points[i+1]);
		float filter_interval = (1.0 - step(1, line_params.y)) * (1.0 - step(line_params.y, 0));
		float dist = line_params.x * filter_interval;
		float l_coord = line_params.y * length(points[i] - points[i+1]) + current_length;
		float lifetime = mix(lifetimes[i] - disappearing, lifetimes[i+1] - disappearing, line_params.y);
		result_color = max(result_color, color * max(1.0, lifetime));
		float act_width = mix(width * 3.0, width, clamp(lifetime, 0.0, 1.0));
		act_width *= smoothstep(total_length, total_length * 0.75, l_coord);
		float v1 = l_coord / 10.0 * lifetime + TIME * 10.0;
		float v2 = l_coord / 15.0 * lifetime + TIME * 15.0;
		float spiral_dist = abs(sin(v1)) * act_width - dist;
		float spiral_dist2 = abs(cos(v2)) * act_width * 0.5 - dist;
		float alpha1 = smoothstep(2.0, 0.0, abs(spiral_dist)) * lifetime;
		float alpha2 = smoothstep(2.0, 0.0, abs(spiral_dist2)) * lifetime;
		float alpha =  max(alpha1, alpha2) * filter_interval;
		result_alpha = max(result_alpha, alpha);
		current_length += length(points[i] - points[i+1]);
		
		//float test = smoothstep(4.0, 3.0, length(points[i] - xy));
		//result_alpha = max(result_alpha, test);
	}
	
	COLOR = vec4(result_color, result_alpha);
}
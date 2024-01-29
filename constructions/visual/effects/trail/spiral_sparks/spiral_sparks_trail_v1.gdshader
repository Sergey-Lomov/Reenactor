shader_type canvas_item;

#define MAX_POINTS 		300

uniform vec3 color: source_color;
uniform float width;				//In pixels
uniform vec2 texture_size;			//In pixels

uniform int points_count;
uniform vec2 points[MAX_POINTS];		//Points coords in pixels
uniform float lifetimes[MAX_POINTS];	//Points lifetimes
uniform float disappearing;				//Disappearing duration

float random(in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

//float normal_dist(vec2 a, vec2 b, vec2 p)
//{
	//vec2 ba = b - a;
    //return (ba.x * (p.y - a.y) - ba.y * (p.x - a.x)) / length(ba);
//}

struct DistInfo {
	float dist;
	float l_coord;
	vec2 vector;
};

//In return vec2 x is full length and y is point position at line
DistInfo line_segment(in vec2 p, in vec2 a, in vec2 b) {
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	vec2 h_to_pa = h * ba - pa;
	return DistInfo(length(h_to_pa), h, h_to_pa);
}

void fragment() {
	vec2 xy = vec2(texture_size) * UV;
	vec3 result_color = vec3(0.0);
	float result_alpha = 0.0;
	
	for (int i = 0; i < points_count - 1; i++) {
		DistInfo dist_info = line_segment(xy, points[i], points[i+1]);
		float dist = dist_info.dist;
		float l_coord = dist_info.l_coord;
		float lifetime = mix(lifetimes[i] - disappearing, lifetimes[i+1] - disappearing, l_coord);
		result_color = max(result_color, color * step(0, dist));
		float act_width = mix(width * 2.0, width, clamp(lifetime, 0.0, 1.0));
		//float alpha = smoothstep(act_width, act_width - 2.0, dist) * lifetime;
		float alpha = step(dist, act_width) * lifetime;
		float noise = random(ceil((xy + dist_info.vector * lifetime) / 1.0));
		alpha *= smoothstep(0.9, 1.0, noise);
		alpha *= sin(TIME * noise * 3.0) * 0.25 + 0.5;
		result_alpha = max(result_alpha, alpha);
	}
	
	COLOR = vec4(result_color, result_alpha);
}

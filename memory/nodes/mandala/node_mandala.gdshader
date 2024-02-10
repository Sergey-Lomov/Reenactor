shader_type canvas_item;

#include "res://utils/shaders/line_segment.gdshaderinc"
#define MAX_POINTS 		4000
#define MAX_CURVES		20

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec2 points[MAX_POINTS];
uniform int curves_count;
uniform int curve_sizes[MAX_CURVES];

uniform vec2 texture_size;
uniform float zoom;
uniform float width;
uniform vec4 main_color: source_color;

const float smooth_dist = 1.7;

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;
	vec4 color = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	int points_delta = 0;
	for (int ci = 0; ci < curves_count; ci++) {
		for (int pi = points_delta; pi < curve_sizes[ci] + points_delta - 1; pi++) {
			float segment_value = line_segment(xy, points[pi], points[pi+1], width, act_smooth);
			color = mix(color, main_color, segment_value);
		}
		points_delta += curve_sizes[ci];
	}
	
	COLOR = color;
}
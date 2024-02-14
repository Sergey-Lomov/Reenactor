shader_type canvas_item;

//#include "res://utils/shaders/line_segment.gdshaderinc"
#define MAX_LINES 		1500

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec2 from_points[MAX_LINES];
uniform vec2 to_points[MAX_LINES];
uniform int lines_count;
uniform int sectors;
uniform vec2 texture_size;
uniform float zoom;
uniform float width;
uniform vec4 main_color: source_color;

const float smooth_dist = 1.7;

float line_segment(vec2 _xy, vec2 _from, vec2 _to, float _width, float out_border, float in_border) {
	vec2 act_to = _to - _from;
	vec2 act_xy = _xy - _from;
	float h = clamp(dot(act_xy, act_to) / dot(act_to, act_to), 0., 1.);
	float dist = length(act_xy - h * act_to);
	float value = smoothstep(out_border, in_border, dist);
	return value;
}

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;
	float out_border = (width + act_smooth) / 2.0;
	float in_border = (width - act_smooth) / 2.0;
	vec4 color = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	float sector_angle = TAU / float(sectors);
	float angle = atan(xy.y, xy.x);
	float norm_angle = mod(angle, sector_angle);
	vec2 norm_xy = vec2(cos(norm_angle), sin(norm_angle)) * length(xy);
	
	for (int i = 0; i < lines_count; i++) {
		float segment_value = line_segment(norm_xy, from_points[i], to_points[i], width, out_border, in_border);
		color = mix(color, main_color, segment_value);
	}

	COLOR = color;
}
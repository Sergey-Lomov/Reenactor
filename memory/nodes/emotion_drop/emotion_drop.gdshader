shader_type canvas_item;

#include "res://utils/shaders/circle.gdshaderinc"

uniform vec2 texture_size;
uniform float radius;
uniform vec3 main_color: source_color;
uniform vec3 border_color: source_color;
uniform float border_width;
uniform float zoom = 1.0;

const float smooth_dist = 1.7;

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;
	COLOR = circle(xy, vec2(0.0), radius, main_color, border_width, border_color, act_smooth);
}
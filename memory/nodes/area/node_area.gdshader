shader_type canvas_item;

#include "res://utils/shaders/circle.gdshaderinc"
#define MAX_CONNECTORS 24

uniform vec2 texture_size;
uniform float radius;
uniform float connectors[MAX_CONNECTORS];
uniform int connectors_count;
uniform float connector_displacement;
uniform float connector_radius;
uniform vec3 main_color: source_color;
uniform vec3 border_color: source_color;
uniform float border_width;
uniform float zoom = 1.0;

const float smooth_dist = 1.7;

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;	
	vec4 color = circle(xy, vec2(0.0), radius, main_color, border_width, border_color, act_smooth);
	
	float out_border = connector_radius + act_smooth / 2.0;
	float in_border = connector_radius - act_smooth / 2.0;
	for (int i = 0; i < connectors_count; i++) {
		float angle = connectors[i];
		vec2 center = vec2(cos(angle), sin(angle)) * (radius + connector_displacement);
		float dist = length(xy - center);
		float border_dist = abs(dist - border_width);
		float alpha = smoothstep(in_border, out_border, dist);
		color = vec4(color.rgb, color.a * alpha);
		float border_alpha = smoothstep(in_border, out_border, border_dist);
		color = vec4(mix(border_color, color.rgb, border_alpha), color.a);
	}
	
	COLOR = color;
}

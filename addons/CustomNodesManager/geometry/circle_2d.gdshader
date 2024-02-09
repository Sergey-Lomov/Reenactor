shader_type canvas_item;

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
	
	float dist = length(xy);
	float alpha = smoothstep(radius + smooth_dist / 2.0, radius - smooth_dist / 2.0, dist);
	vec3 color = main_color;// * step(radius + smooth_dist / 2.0, dist);
	
	float border_dist = abs(dist - radius);
	float out_border = (border_width + act_smooth) / 2.0;
	float in_border = (border_width - act_smooth) / 2.0;
	float border_alpha = smoothstep(out_border, in_border, border_dist);
	border_alpha *= step(0.01, border_width);
	color = mix(color, border_color, border_alpha);
	alpha = max(alpha, border_alpha);
	
	COLOR = vec4(color, alpha);
}

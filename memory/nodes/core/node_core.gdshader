shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec2 texture_size;
uniform float zoom = 1.0;
uniform vec4 core_color: source_color;
uniform float core_radius;
uniform vec4 border_color: source_color;
uniform float border_width;

uniform int ray_count;
uniform vec4 ray_color1: source_color;
uniform vec4 ray_border_color1: source_color;
uniform float ray_length1;
uniform vec4 ray_color2: source_color;
uniform vec4 ray_border_color2: source_color;
uniform float ray_length2;
uniform float ray_border_width;

const float smooth_dist = 1.7;

struct dist_info {
	float dist;
	float l_coord;
};

struct ray_config {
	float radius;
	float angle_step; 
	float out_border;
	float in_border;
	vec4 body_color;
	vec4 border_color;
};

dist_info line_dist(in vec2 p, in vec2 a, in vec2 b) {
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return dist_info(length(pa - h * ba), h);
}

bool in_triangle(in vec2 a, in vec2 b, in vec2 c, in vec2 p)
{
  float r = (p.x - a.x) * (p.y - b.y) - (p.x - b.x) * (p.y - a.y);
  float s = (p.x - b.x) * (p.y - c.y) - (p.x - c.x) * (p.y - b.y);
  float t = (p.x - c.x) * (p.y - a.y) - (p.x - a.x) * (p.y - c.y);
  return  ((r * s) > 0.0) && ((r * t) > 0.0);
}

vec4 apply_ray(float index, vec2 xy, ray_config config, vec4 color) {
	float ray_angle = index * config.angle_step;
	vec2 ray_vertex = vec2(cos(ray_angle), sin(ray_angle)) * (config.radius + core_radius);
		
	float p1_angle = config.angle_step * (index + 0.5);
	float p2_angle = config.angle_step * (index - 0.5);
	vec2 ray_p1 = vec2(cos(p1_angle), sin(p1_angle)) * core_radius;
	vec2 ray_p2 = vec2(cos(p2_angle), sin(p2_angle)) * core_radius;
	
	float ray_border_dist1 = line_dist(xy, ray_vertex, ray_p1).dist;
	float ray_border_dist2 = line_dist(xy, ray_vertex, ray_p2).dist;
	float ray_border_dist = min(ray_border_dist1, ray_border_dist2);
	float ray_body_alpha = float(in_triangle(ray_p1, ray_p2, ray_vertex, xy));
	float ray_border_alpha = smoothstep(config.out_border, config.in_border, ray_border_dist);
	float ray_alpha = max(ray_body_alpha, ray_border_alpha);
	float color_balance = step(ray_border_dist, config.out_border)  * (1.0 - ray_body_alpha) + ray_border_alpha * ray_body_alpha;
	color = mix(color, config.body_color, ray_body_alpha);
	color = mix(color, config.border_color, ray_border_alpha);
	
	return color;
}

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;
	vec4 color = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	float ray_angle_step = PI * 2.0 / float(ray_count);
	float ray_out_border = (ray_border_width + act_smooth) / 2.0;
	float ray_in_border = (ray_border_width - act_smooth) / 2.0;
	
	float rl1 = ray_length1 * (cos(TIME) / 8.0 + 0.75);
	float rl2 = ray_length2 * (cos(TIME + PI) / 8.0 + 0.75);
	ray_config c1 = ray_config(rl1, ray_angle_step, ray_out_border, ray_in_border, ray_color1, ray_border_color1);
	ray_config c2 = ray_config(rl2, ray_angle_step, ray_out_border, ray_in_border, ray_color2, ray_border_color2);
	
	for (int i = 0; i < ray_count; i++) {
		float act_i = float(i) + TIME / 4.0;
		color = apply_ray(act_i, xy, c2, color);
	}
	
	for (int i = 0; i < ray_count; i++) {
		float act_i = float(i) + TIME / 4.0;
		color = apply_ray(act_i - 0.5, xy, c1, color);
	}
	
	float core_dist = length(xy);
	float core_alpha = step(core_dist, core_radius);
	color = mix(color, core_color, core_alpha);
	
	float border_dist = abs(core_dist - core_radius);
	float out_border = (border_width + act_smooth) / 2.0;
	float in_border = (border_width - act_smooth) / 2.0;
	float border_alpha = smoothstep(out_border, in_border, border_dist);
	color = mix(color, border_color, border_alpha);
	
	COLOR = vec4(color);
}
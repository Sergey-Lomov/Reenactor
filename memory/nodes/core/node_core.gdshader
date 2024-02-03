shader_type canvas_item;

uniform vec2 texture_size;
uniform float zoom = 1.0;
uniform vec3 core_color: source_color;
uniform float core_radius;
uniform vec3 border_color: source_color;
uniform float border_width;

uniform int ray_count;
uniform vec3 ray_color1: source_color;
uniform vec3 ray_border_color1: source_color;
uniform float ray_length1;
uniform vec3 ray_color2: source_color;
uniform vec3 ray_border_color2: source_color;
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
	vec3 body_color;
	vec3 border_color;
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

vec4 apply_ray(float index, vec2 xy, ray_config config, vec3 color, float alpha) {
	float ray_angle = index * config.angle_step;
	vec2 ray_vertex = vec2(cos(ray_angle), sin(ray_angle)) * (config.radius + core_radius);
		
	float p1_angle = config.angle_step * (index + 0.5);
	float p2_angle = config.angle_step * (index - 0.5);
	vec2 ray_p1 = vec2(cos(p1_angle), sin(p1_angle)) * core_radius;
	vec2 ray_p2 = vec2(cos(p2_angle), sin(p2_angle)) * core_radius;
	vec2 ray_p0 = (ray_p1 - ray_p2) / 2.0 + ray_p1;
	
	float ray_border_dist1 = line_dist(xy, ray_vertex, ray_p1).dist;
	float ray_border_dist2 = line_dist(xy, ray_vertex, ray_p2).dist;
	float ray_border_dist = min(ray_border_dist1, ray_border_dist2);
	float ray_body_alpha = float(in_triangle(ray_p1, ray_p2, ray_vertex, xy));
	float ray_border_alpha = smoothstep(config.out_border, config.in_border, ray_border_dist);
	float ray_alpha = max(ray_body_alpha, ray_border_alpha);
	
	color = mix(color, config.body_color, ray_alpha);
	color = mix(color, config.border_color, ray_border_alpha);
	alpha = max(alpha, ray_alpha);
	
	return vec4(color, alpha);
	
	//float rv_alpha = smoothstep(6.0, 5.0, length(xy - ray_p1));
	//color = mix(color, vec3(0.75, 0.0, 0.5), step(0.1, rv_alpha));
	//alpha = max(alpha, rv_alpha);
	//
	//float rv_alpha2 = smoothstep(6.0, 5.0, length(xy - ray_p2));
	//color = mix(color, vec3(0.75, 0.0, 0.5), step(0.1, rv_alpha2));
	//alpha = max(alpha, rv_alpha2);
	
	//float rv_alpha2 = smoothstep(6.0, 5.0, length(xy - ray_vertex));
	//color = mix(color, vec3(0.5, 0.0, 0.75), step(0.1, rv_alpha2));
	//alpha = max(alpha, rv_alpha);
	
	//COLOR = vec4(vec3(ray_body_alpha), 1.0);
}

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;
	float alpha = 0.0;
	vec3 color = vec3(0.0);
	
	float ray_angle_step = PI * 2.0 / float(ray_count);
	float ray_out_border = (ray_border_width + act_smooth) / 2.0;
	float ray_in_border = (ray_border_width - act_smooth) / 2.0;
	
	float rl1 = ray_length1 * (cos(TIME) / 8.0 + 0.75);
	float rl2 = ray_length2 * (cos(TIME + PI) / 8.0 + 0.75);
	ray_config c1 = ray_config(rl1, ray_angle_step, ray_out_border, ray_in_border, ray_color1, ray_border_color1);
	ray_config c2 = ray_config(rl2, ray_angle_step, ray_out_border, ray_in_border, ray_color2, ray_border_color2);
	
	for (int i = 0; i < ray_count; i++) {
		float act_i = float(i) + TIME / 4.0;
		vec4 r = apply_ray(act_i, xy, c1, color, alpha);
		color = r.rgb;
		alpha = r.a;
	}
	
	for (int i = 0; i < ray_count; i++) {
		float act_i = float(i) + TIME / 4.0;
		vec4 r2 = apply_ray(act_i - 0.5, xy, c2, color, alpha);
		color = r2.rgb;
		alpha = r2.a;
	}
	
	float core_dist = length(xy);
	float core_alpha = step(core_dist, core_radius);
	color = mix(color, core_color, core_alpha);
	alpha = max(alpha, core_alpha);
	
	float border_dist = abs(core_dist - core_radius);
	float out_border = (border_width + act_smooth) / 2.0;
	float in_border = (border_width - act_smooth) / 2.0;
	float border_alpha = smoothstep(out_border, in_border, border_dist);
	color = mix(color, border_color, border_alpha);
	alpha = max(alpha, border_alpha);
	
	COLOR = vec4(color, alpha);
}
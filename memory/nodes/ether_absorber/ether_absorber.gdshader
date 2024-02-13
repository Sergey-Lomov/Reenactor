shader_type canvas_item;

#include "res://utils/shaders/circle.gdshaderinc"
#include "res://utils/shaders/overlap.gdshaderinc"

uniform vec2 texture_size;
uniform float zoom = 1.0;
uniform float core_radius;
uniform vec3 main_color: source_color;
uniform vec3 border_color: source_color;
uniform float core_border;
uniform vec2 center;
uniform float mid_angle;
uniform float absorb_sector;
uniform float absorb_distance;
uniform float particle_absorb_duration;
uniform int particles_count;
uniform float particle_radius;
uniform float particle_border;

const float smooth_dist = 1.7;
const float appear_duration = 0.75;

float random(float p) {
    return fract(sin(dot(p, 311.7))*43758.545);
}

vec4 particle(vec2 xy, float time, vec3 color, float radius, float smootinhg) {
	float time_step = floor(time / particle_absorb_duration);
	float local_time = time / particle_absorb_duration - time_step;
	float angle = mid_angle + (absorb_sector * (random(time_step) - 0.5));
	float dist = absorb_distance * smoothstep(0.0, 1.0, (1.0 - local_time));
	vec2 p_center = vec2(cos(angle), sin(angle)) * dist;
	float appearing = smoothstep(0.0, appear_duration, local_time);
	float act_radius = radius * appearing;
	return circle(xy, p_center, act_radius, color, 0.0, vec3(0.0), smootinhg);
}

void fragment() {
	vec2 xy = (UV - 0.5) * texture_size;
	float act_smooth = smooth_dist / zoom;
	float time_step = particle_absorb_duration / float(particles_count) + particle_absorb_duration;
	
	float cb_radius = core_radius + core_border * 0.5;
	vec4 color = circle(xy, center, cb_radius, border_color, 0, vec3(0.0), act_smooth);

	for (int i = 0; i < particles_count; i++) {
		float pb_radius = particle_radius + particle_border * 0.5;
		vec4 pb = particle(xy, TIME + float(i) * time_step, border_color, pb_radius, act_smooth);
		color = overlap(color, pb);
	}
	
	float cf_radius = core_radius - core_border * 0.5;
	vec4 core_front = circle(xy, center, cf_radius, main_color, 0, vec3(0.0), act_smooth);
	color = overlap(color, core_front);
	
	for (int i = 0; i < particles_count; i++) {
		float pf_radius = particle_radius - particle_border * 0.5 ;
		vec4 pf = particle(xy, TIME + float(i) * time_step, main_color, pf_radius, act_smooth);
		color = overlap(color, pf);
	}
		
	COLOR = color;
}

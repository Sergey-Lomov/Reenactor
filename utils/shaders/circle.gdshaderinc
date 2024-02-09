vec4 cirle(vec2 xy, 
		vec2 center, 
		float radius, 
		vec3 main_color, 
		float border, 
		vec3 border_color, 
		float smoothing) {
	float dist = length(xy - center);
	float main_alpha = smoothstep(radius + smoothing / 2.0, radius - smoothing / 2.0, dist);
	vec3 color = main_color * (1.0 - step(main_alpha, 0.0));
	
	float border_dist = abs(dist - radius);
	float out_border = (border + smoothing) / 2.0;
	float in_border = (border - smoothing) / 2.0;
	float border_alpha = smoothstep(out_border, in_border, border_dist);
	float mix_value = clamp(1.0, 0.0, step(radius, dist) + border_alpha);
	mix_value *= 1.0 - step(border, 0.0);
	color = mix(color, border_color, mix_value);
	
	return vec4(color, max(main_alpha, border_alpha));
}
vec4 circle(vec2 _xy, 
		vec2 _center, 
		float _radius, 
		vec3 _main_color, 
		float _border, 
		vec3 _border_color, 
		float _smoothing) {
	float dist = length(_xy - _center);
	float main_alpha = smoothstep(_radius + _smoothing / 2.0, _radius - _smoothing / 2.0, dist);
	vec3 color = _main_color * (1.0 - step(main_alpha, 0.0));
	
	float border_dist = abs(dist - _radius);
	float out_border = (_border + _smoothing) / 2.0;
	float in_border = (_border - _smoothing) / 2.0;
	float border_alpha = smoothstep(out_border, in_border, border_dist);
	float mix_value = clamp(1.0, 0.0, step(_radius, dist) + border_alpha);
	mix_value *= 1.0 - step(_border, 0.0);
	color = mix(color, _border_color, mix_value);
	
	return vec4(color, max(main_alpha, border_alpha));
}
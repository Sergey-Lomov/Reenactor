float line_segment(vec2 _xy, vec2 _from, vec2 _to, float _width, float _smoothing) {
	vec2 act_to = _to - _from;
	vec2 act_xy = _xy - _from;
	float h = clamp(dot(act_xy, act_to) / dot(act_to, act_to), 0., 1.);
	float dist = length(act_xy - h * act_to);
	
	float out_border = (_width + _smoothing) / 2.0;
	float in_border = (_width - _smoothing) / 2.0;
	float value = smoothstep(out_border, in_border, dist);
	return value;
}
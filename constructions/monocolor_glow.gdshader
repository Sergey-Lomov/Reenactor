shader_type canvas_item;
uniform int search_step = 1;
uniform int glow_radius = 5;

void fragment() {
	ivec2 center = ivec2(vec2(textureSize(TEXTURE, 0)) * UV);
	int search_radius = glow_radius;
	float min_dist = -1.0;
	vec3 s_color = vec3(0.0);

	while (search_radius <= glow_radius) {
		for (int x = center.x - search_radius; x <= center.x + search_radius; x += search_step) {
			for (int y = center.y - search_radius; y <= center.y + search_radius; y += search_step) {
				ivec2 cursor = ivec2(x, y);
				vec4 c_color = texelFetch(TEXTURE, cursor, 0);
				if (c_color.a == 1.0) {
					float dist = sqrt(pow(float(center.x-cursor.x), 2.0) + pow(float(center.y-cursor.y), 2.0));//length(vec2(center - cursor));
					if (dist < min_dist || min_dist < 0.0) {
						min_dist = dist;
						s_color = c_color.rgb;
					}
				}
			}
		}
		search_radius += search_step;
	}

	//float alpha = max(1.0 - min_dist / float(glow_radius), 0.0);
	//float act_dist = smoothstep(0.0, 0.95, 1.0 - min_dist / float(glow_radius));
	float act_dist = min_dist;
	act_dist = step(0.0, min_dist) * act_dist * 0.6;
	//COLOR = vec4(vec3(0.0, float(center.x) / 100.0, float(center.y) / 100.0), 1.0);
	//float color_adapter = max(1.0, (0.5 + act_dist));
	vec3 r_color = s_color/act_dist;
	float alpha = 1.0 - smoothstep(0.0, float(glow_radius), min_dist);
	alpha *= step(0.0, min_dist);
	COLOR = vec4(r_color, alpha);
	//COLOR = texelFetch(TEXTURE, center, 0);
}

vec4 overlap(vec4 c1, vec4 c2) {
	return vec4(mix(c1.rgb, c2.rgb, c2.a), c1.a + c2.a);
}
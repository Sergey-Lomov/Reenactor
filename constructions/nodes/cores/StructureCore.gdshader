shader_type canvas_item;
uniform vec3 color1 = vec3(1.0);
uniform vec3 color2 = vec3(1.0);

uniform float focus = 0.9;
const float mid_coeff = 0.25;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

void fragment() {
	vec2 st = UV * 3.0; //Scaling
	vec2 i_st = floor(st);
    vec2 f_st = fract(st);
	float m_dist = 1.;  // minimum distance
	float t = TIME * 0.5;
	
    for (int y= -1; y <= 1; y++) {
        for (int x= -1; x <= 1; x++) {
            vec2 neighbor = vec2(float(x),float(y)); // Neighbor place in the grid
            vec2 point = random2(i_st + neighbor); // Random position from current + neighbor place in the grid
            point = 0.5 + 0.5 * sin(t + 6.9*point); // Animate the point
            vec2 diff = neighbor + point - f_st; // Vector between the pixel and the point
            float dist = length(diff); // Distance to the point
            m_dist = min(m_dist, dist); // Keep the closer distance
        }
    }
	//float d = max(sin((length(UV - 0.5) - TIME * 0.2) * 40.0), 0.0);//cos(TIME) * 0.5 + 0.5;
	//float t = TIME * 0.2;
	//float d = -1.0 * (pow(sin(t+0.4), 256.0) / 6.0 + pow(sin(t), 63.0) * sin(t+1.5) * 8.0);//sin(TIME) / 10.0 + 0.2;
	//COLOR = vec4(mix(color, vec3(1.0), max(d, 0.0)), alpha);
	vec3 result_color = mix(color1, color2, pow(m_dist, 2.0) * 1.0);
	
	vec2 centered = UV - 0.5;
	float d = dot(centered, centered) * 4.0;
	float t1 = (1.0 - smoothstep(focus, focus * mid_coeff, d));
	float t2 = 1.0 - smoothstep(focus, 1, d);
	COLOR = vec4(mix(result_color, color2, t1), t2);
	
	//COLOR = vec4(result_color, alpha);
}
shader_type canvas_item;

#define MAX_POINTS 		4000
#define sfract(x)  		min( fract(x)/(1.-fwidth(x)), fract(-(x))/fwidth(x) )

uniform vec3 color: source_color;
uniform int points_count;
uniform vec2 points[MAX_POINTS];

const vec2 charge_source = vec2(0.5, 0.6);

//TODO: Unused?
vec2 random2(vec2 p) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

//TODO: Unused?
float line_segment(in vec2 p, in vec2 a, in vec2 b) {
	vec2 ba = b - a;
	vec2 pa = p - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0., 1.);
	return length(pa - h * ba);
}

float poly_distance(vec2 p) {
	float d = dot(p-points[0],p-points[0]);
    float s = 1.0;
    for( int i=0, j=points_count-1; i<points_count; j=i, i++ )
    {
        vec2 e = points[j] - points[i];
        vec2 w = p - points[i];
        vec2 b = w - e*clamp( dot(w,e)/dot(e,e), 0.0, 1.0 );
        d = min( d, dot(b,b) );
        bvec3 c = bvec3(p.y>=points[i].y,p.y<points[j].y,e.x*w.y>e.y*w.x);
        if( all(c) || all(not(c)) ) s*=-1.0;  
    }
    
	return s*sqrt(d);
}

float getGlow(float dist, float radius, float intensity){
    return pow(radius/abs(dist), intensity);
}

void fragment() {
	//Base line draw implementation
	//float dist = 1.0;
	//for (int i = 1; i < points_count; i++) {
		//float d = line_segment(UV, points[i], points[i-1]) - 0.001;
		//dist = min(d, dist);
	//}
	
	//Advanced polygon draw implamentation
	float dist = poly_distance(UV);
	float act_dist = smoothstep(0.005, 0.0, abs(dist));
	vec3 result = color * act_dist;

	//Add glow
	float glow = getGlow(dist, 0.003, 0.95);
	result += glow * color * smoothstep(-0.015, 0.001, dist);


	//float cp_dist = 1.0 - length(UV - vec2(0.25, 0.25));
	//cp_dist = smoothstep(0.9, 1.0, cp_dist);
	//vec3 t_color = color + 0.3*cos(250.0*dist + TIME * 10.0);

	//TODO: Check is really necessary to use sfract insted fract.
	//This may produce unnecessary calculations when result will be animated
	//vec2 dist_controller = vec2(0.6, 0.59);
	//float controller_dist = length(dist_controller - UV);
	//result = mix(result, vec3(0.0, 0.5, 1.0), smoothstep(0.007, 0.005, controller_dist));
	//
	//float wave_dist = dist - smoothstep(0.1, 0.0, controller_dist) * 0.025;
	//float dist_wave = smoothstep(0.5, 1.0, sfract(wave_dist * 20.0 - TIME * 0.5));
	//vec3 dist_waves_color = color * dist_wave;
	//dist_waves_color *= step(dist, 0.0);
		////float a_cos = acos( dot(normalize(UV - charge_source), vec2(sin(TIME), cos(TIME))));
		////float angle_mult = smoothstep(0.99 * PI, PI, a_cos);
		////t_color *= max(angle_mult, 0.03);
	//result = max(result, dist_waves_color);
	
	//vec3 t_color = color;
	//t_color *= 1.0 - exp(-6.0*abs(dist));
	//t_color *= 0.5+ 0.2*cos(140.0*dist - TIME);
	//t_color = mix( t_color, color, 1.0-smoothstep(0.0, 0.003,abs(dist)) );
	//t_color *= step(dist, 0.0);
	//result = max(result, t_color);

	//Charge particles
	//vec2 p_center = vec2(fract(TIME * 0.133) + charge_source.x, charge_source.y);
	//float p_dist = length(UV - p_center);
	//vec3 p_color = vec3(1.0, 0.5, 0.0) * smoothstep(0.008, 0.007, p_dist) * step(dist, -0.001); // -0.001 is glow inner gap
	//result = mix(result, p_color, smoothstep(0.008, 0.007, p_dist));
	//result = max(result, p_color);

	//TODO: Remove testing code
	//float center_dist = length(vec2(0.5) - UV);
	//result = mix(result, vec3(1.0, 0.5, 0.0), smoothstep(0.015, 0.012, center_dist));
	
	//float demo = acos( dot(normalize(UV - 0.5), vec2(sin(TIME), cos(TIME))));
	//result = vec3(demo);
	//result = vec3(smoothstep(0.49 * PI, 0.5 * PI, sin_v));
	
	
	//Core-like experiment
	vec2 st = UV * 6.0; //Scaling
	vec2 i_st = floor(st);
    vec2 f_st = fract(st);
	float m_dist = 0.8;
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
	
	vec3 cloud_color = color * 0.7;//vec3(0.45, 0.2, 0.3);
	cloud_color = mix(cloud_color * 0.3, cloud_color * 1.5, pow(m_dist, 2.0) * 1.5);
	cloud_color *= step(dist, -0.001);
	result = max(cloud_color, result); 
	
	COLOR = vec4(result, 1.0/*alpha*/);
}

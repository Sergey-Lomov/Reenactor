shader_type canvas_item;

#define MAX_POINTS 		4000
#define sfract(x)  		min( fract(x)/(1.-fwidth(x)), fract(-(x))/fwidth(x) )

uniform vec3 color: source_color;
uniform int points_count;
uniform vec2 points[MAX_POINTS];

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
	//result *= 1.0 - exp(-6.0*abs(dist));
	//result *= 0.8 + 0.2*cos(140.0*dist);
	//result = mix( result, color, 1.0-smoothstep(0.0, 0.003,abs(dist)) );

	//Add glow
	float glow = getGlow(dist, 0.003, 0.95);
	result += glow * color * smoothstep(-0.015, 0.001, dist);


	//float cp_dist = 1.0 - length(UV - vec2(0.25, 0.25));
	//cp_dist = smoothstep(0.9, 1.0, cp_dist);
	//vec3 t_color = color + 0.3*cos(250.0*dist + TIME * 10.0);

	//TODO: Check is really necessary to use sfract insted fract.
	//This may produce unnecessary calculations when result will be animated
	vec3 t_color = color * (1.0 - sfract(dist * 25.0 - TIME * 0.25));
	t_color *= 0.5 * step(dist, 0.0);
	result = max(result, t_color);

	COLOR = vec4(result, 1.0/*alpha*/);
}

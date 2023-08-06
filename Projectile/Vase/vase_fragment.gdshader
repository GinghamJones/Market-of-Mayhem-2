shader_type spatial;
render_mode cull_disabled;

uniform vec2 position;
uniform float radius = 0.3;
uniform float u_blur = 0.1;
uniform vec3 face_color : source_color = vec3(0.0);

float Circle(vec2 uv, vec2 p, float r, float blur)
{
	float d = length(uv + p);
	float c = smoothstep(r, r - blur, d);
	return c;
}


float Band(float t, float start, float end, float blur) 
{
	float step1 = smoothstep(start - blur, start + blur, t);
	float step2 = smoothstep(end + blur, end - blur, t);
	return step1 * step2;
}

float Rect(vec2 uv, float left, float right, float bottom, float top, float blur) 
{
	float band1 = Band(uv.x, left, right, blur);
	float band2 = Band(uv.y, bottom, top, blur);
	return band1 * band2;
}

void vertex()
{
	
}

void fragment() 
{
	vec2 uv = UV;
	uv -= 0.5;
	uv.y -= sin((uv.x * 10.0) * 0.5);
	//uv.x *= (SCREEN_UV.x / SCREEN_UV.y) + 0.5;
	float rect = Rect(uv, -0.1, 0.1, -0.4, 0.4, 0.1 );
	vec3 color = vec3(face_color) * rect;
	
	ALBEDO = color * COLOR.rgb;
	ALPHA = rect * 0.6;
}

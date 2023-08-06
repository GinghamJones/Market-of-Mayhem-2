shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 shine_color : source_color = vec4(230, 12, 0, 0);
uniform float cycle_interval : hint_range(0.5, 5.0) = 1.0;
uniform float shine_speed : hint_range(1.0, 5.0) = 3.0;
uniform float shine_width : hint_range(0.0, 100.0) = 3.0;

uniform bool is_on = false;

void fragment() {
	if (is_on){
		vec3 vertex = (VIEW_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
		float width = shine_width * 0.001 * cycle_interval;
		float frequency = floor(sin(cycle_interval + UV.x) + 6.0 * cycle_interval);
		ALBEDO = shine_color.rgb;
		ALPHA = clamp((1.0 - dot(NORMAL, VIEW)) * frequency * shine_color.a, 0.0, 1.0);
	}
	else{
		ALBEDO = vec3(1.0, 0.0, 0.0);
		ALPHA = 0.0;
	}
}

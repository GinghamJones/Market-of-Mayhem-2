shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform vec4 shine_color : source_color = vec4(230, 12, 0, 117);
uniform float shine_speed : hint_range(1.0, 5.0) = 3.0;
uniform float shine_width : hint_range(0.0, 100.0) = 3.0;
uniform bool is_on = false;


void fragment() {
	if (is_on){
		ALBEDO = shine_color.rgb;
		ALPHA = clamp((1.0 - dot(NORMAL, VIEW)) * shine_color.a, 0.0, 1.0);
	}
	else{
		ALPHA = 0.0;
	}
}

shader_type canvas_item;
uniform bool active = false;
uniform vec2 center = vec2(0.5,0.5);
uniform float screen_ratio = 1.77777;
uniform float wave_size = 0.1;
uniform vec2 wave_scale = vec2(10.0,0.8);
uniform float wave_depreciation = 40.0;
uniform float time = -0.1;

void fragment(){
	if (active){
	vec4 col = texture(SCREEN_TEXTURE,SCREEN_UV);
	
	vec2 uv = SCREEN_UV;
	uv.y /= screen_ratio;
	vec2 new_center = vec2(center.x,center.y/screen_ratio);
	
	float dist = distance(uv,new_center);
	
	if (dist <= time + wave_size && dist >= time - wave_size){
		
		float difference = dist - time;
		float scale = (1.0 - pow(abs(difference * wave_scale.x),wave_scale.y));
		float time_difference = difference * scale;
		
		vec2 new_coords = normalize(uv - new_center - vec2(-0.8,-0.8));
		float decrease = time * dist * wave_depreciation;
		
		new_coords += (uv * time_difference) / decrease;
		col = texture(SCREEN_TEXTURE,new_coords);
		col += (col * scale) / decrease;
		
	}
	COLOR = col;
	}
}
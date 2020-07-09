shader_type canvas_item;
uniform float outline_width = 2.0;
uniform vec4 outline_color: hint_color;
uniform float rotation = 0;

vec2 rotateUV(vec2 uv, vec2 pivot, float r) {
    float cosa = cos(r);
    float sina = sin(r);
    uv -= pivot;
    return vec2(
        cosa * uv.x - sina * uv.y,
        cosa * uv.y + sina * uv.x 
    ) + pivot;
}

void fragment(){
	vec2 uv = rotateUV(UV,vec2(0.5),rotation);
    vec4 col = texture(TEXTURE, uv);
    vec2 ps = TEXTURE_PIXEL_SIZE * outline_width; // multiply only once instead of eight times.
    float a;
    float maxa = col.a;
    float mina = col.a;
	

    for(float y = -1.25; y <= 0.0; y++) {
        for(float x = -1.25 ; x <= 0.0; x++) {
			vec2 rotated = rotateUV(vec2(x,y),vec2(0.0),rotation);
            if(rotated == vec2(0.0)) {
                // ignore the center of kernel
            }
			
			vec2 offset = rotated*ps;
			a = texture(TEXTURE,uv + offset).a;
            maxa = max(a, maxa); 
            mina = min(a, mina);
        }
    }

    // Fill transparent pixels only, don't overlap texture
    if(col.a == 0.0) {
        COLOR = mix(col, outline_color, maxa-mina);
    } else {
        // Note on old code: if the last mix value is always 0, why even use it?
        COLOR = col;
    }
}


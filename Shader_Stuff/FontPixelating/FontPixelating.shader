shader_type canvas_item;

void fragment(){
    vec4 curr_color = texture(TEXTURE,UV);
	COLOR.a = (curr_color.a < 0.5) ? 0.0 : 1.0;
}
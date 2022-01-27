shader_type canvas_item;

void fragment(){
    vec4 texture_color = texture(TEXTURE,UV);
	
	// 文字阴影的颜色不能通过TEXTURE获取，Godot已经将其上色至COLOR内，并将其从TEXTURE中剔除
	// 所以这里检测一下TEXTURE内颜色是否不为默认值1f（即是否被剔除）
	// 为了防止修改想覆盖的颜色后没有覆盖，所以检测TEXTURE而不是COLOR
	if (texture_color.a != 1f)
		COLOR.a = texture_color.a;
	if (texture_color.r != 1f)
		COLOR.r = texture_color.r;
	if (texture_color.g != 1f)
		COLOR.g = texture_color.g;
	if (texture_color.b != 1f)
		COLOR.b = texture_color.b;
}
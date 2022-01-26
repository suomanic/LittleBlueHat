shader_type canvas_item;

void fragment(){
    vec4 curr_color = texture(TEXTURE,UV);
	COLOR.a = (curr_color.a < 0.5f) ? 0f : 1f;
	// label内文字阴影的颜色不能通过texture(TEXTURE,UV)获取，Godot已经将其上色至COLOR内，
	// 所以这里检测一下COLOR是否有设置RGB。
	// (用默认值1f判断。如果已经上色但是颜色也为全1，那么重复上一次全1也没有影响)
	if (COLOR.rgb == vec3(1f, 1f, 1f))
		COLOR.rgb = curr_color.rgb;
}
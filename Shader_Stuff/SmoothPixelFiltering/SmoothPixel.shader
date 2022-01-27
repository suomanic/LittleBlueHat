shader_type canvas_item;
render_mode unshaded;

// Texture must have 'Filter'-flag enabled!

// Automatic smoothing
// independent of geometry and perspective
vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size)
{
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}

void fragment()
{
	vec4 texture_color = texturePointSmooth(TEXTURE, UV, TEXTURE_PIXEL_SIZE);
	if (texture_color.a != 1f)
		COLOR.a = texture_color.a;
	if (texture_color.r != 1f)
		COLOR.r = texture_color.r;
	if (texture_color.g != 1f)
		COLOR.g = texture_color.g;
	if (texture_color.b != 1f)
		COLOR.b = texture_color.b;
}
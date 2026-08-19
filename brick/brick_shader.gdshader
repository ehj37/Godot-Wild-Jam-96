shader_type canvas_item;

void light() {
	LIGHT_ENERGY;
	float texture_alpha = texture(TEXTURE, UV).a;

	// Arbitrarily deciding that 4 is the max light energy here.
	float light_color_percent = min(LIGHT_ENERGY / 4.0, 1.0);
	LIGHT = vec4(LIGHT_COLOR.rgb * light_color_percent + COLOR.rgb * (1.0 - light_color_percent), texture_alpha);
}

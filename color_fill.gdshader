shader_type canvas_item;

uniform vec3 color: source_color = vec3(1.0);

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	COLOR = vec4(color, COLOR.a);
}

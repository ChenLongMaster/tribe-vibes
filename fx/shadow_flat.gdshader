shader_type canvas_item;
// Bóng của vật chuyển động nhiều mảnh (thổ dân, thú): phép chiếu xuống đất nằm ở transform
// của node cha (ShadowLayer), shader chỉ tô tối theo hình.

uniform float shadow_alpha = 0.25;
uniform vec3 shadow_color : source_color = vec3(0.16, 0.1, 0.2);

void fragment() {
	COLOR = vec4(shadow_color, texture(TEXTURE, UV).a * shadow_alpha);
}

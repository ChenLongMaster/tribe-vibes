shader_type canvas_item;
// Bóng đổ theo mặt trời cho vật đứng yên (cây, đá, nhà): dùng chính hình của vật, tô tối,
// rồi "đổ" xuống mặt đất — điểm cao h (tính từ chân) dời đi h * shadow_vec. Gốc toạ độ
// của sprite phải là chỗ chân chạm đất (đúng như ArtLibrary.setup_sprite đặt). Mọi bóng dùng
// chung một material nên DayNight chỉ cần đặt tham số một lần mỗi frame.

uniform vec2 shadow_vec = vec2(0.0, -0.3);
uniform float shadow_alpha = 0.25;
uniform vec3 shadow_color : source_color = vec3(0.16, 0.1, 0.2);

void vertex() {
	float height = -VERTEX.y;
	VERTEX = vec2(VERTEX.x, 0.0) + height * shadow_vec;
}

void fragment() {
	COLOR = vec4(shadow_color, texture(TEXTURE, UV).a * shadow_alpha);
}

shader_type canvas_item;
// Công trình đang xây "mọc dần" từ dưới lên: phần đã xây vẽ đủ màu, phần chưa xây chỉ là
// bóng mờ nhạt màu — người chơi thấy trước nhà sẽ trông thế nào và đã xây tới đâu.

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float built = step(1.0 - progress, UV.y);
	float grey = dot(color.rgb, vec3(0.3, 0.59, 0.11));
	vec3 faded = mix(vec3(grey), vec3(1.0), 0.45);
	COLOR = vec4(mix(faded, color.rgb, built), color.a * mix(0.32, 1.0, built));
}

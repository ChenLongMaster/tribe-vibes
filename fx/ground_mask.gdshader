shader_type canvas_item;
// Vẽ đất trơ (sân công trình, sân làng, đường mòn) phủ lên nền cỏ từ một ảnh mặt nạ nhỏ (mỗi ô
// map một điểm ảnh): kênh R = độ mòn đường đi, kênh G = sân. Ảnh được phóng to bằng lọc tuyến
// tính nên các ô liền nhau nhoè thành dải / mảng mềm; nhiễu làm mép đất lởm chởm tự nhiên thay
// vì tròn trịa. Cả map chỉ một sprite → một lệnh vẽ (nhẹ cho bản Web).

uniform sampler2D noise_tex : repeat_enable, filter_linear;
// Số ô của map — để nhiễu tính theo ô (không bị giãn theo cỡ map).
uniform vec2 map_cells = vec2(96.0, 72.0);
uniform vec4 dirt_color : source_color = vec4(0.78, 0.64, 0.48, 1.0);
uniform vec4 dirt_dark : source_color = vec4(0.66, 0.52, 0.38, 1.0);
uniform vec4 edge_color : source_color = vec4(0.5, 0.42, 0.26, 1.0);
// Mức mặt nạ bắt đầu thấy đất (đường mờ dần thì lùi xuống dưới mức này là mất).
uniform float threshold = 0.42;

void fragment() {
	vec2 mask = texture(TEXTURE, UV).rg;
	vec2 cells = UV * map_cells;
	float coarse = texture(noise_tex, cells * 0.23).r;
	float fine = texture(noise_tex, cells * 1.9).r;
	float value = max(mask.r, mask.g) + (coarse - 0.5) * 0.32 + (fine - 0.5) * 0.08;
	float alpha = smoothstep(threshold - 0.05, threshold + 0.07, value);
	vec3 color = mix(dirt_color.rgb, dirt_dark.rgb, smoothstep(0.35, 0.8, fine));
	// Viền sẫm mỏng chỗ đất gặp cỏ.
	float edge = smoothstep(threshold - 0.05, threshold + 0.02, value) - smoothstep(threshold + 0.03, threshold + 0.12, value);
	color = mix(color, edge_color.rgb, clamp(edge, 0.0, 1.0) * 0.55);
	COLOR = vec4(color, alpha);
}

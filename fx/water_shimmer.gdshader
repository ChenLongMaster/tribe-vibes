shader_type canvas_item;
// Vệt sáng lăn tăn trôi trên mặt hồ theo gió. Chỉ đổi màu điểm ảnh "xanh nước",
// không đụng dải cát và nét viền bờ — nên dùng được cho mọi hình nước, kể cả art thật.

uniform float wind_time = 0.0;
uniform float wind_strength = 0.5;
uniform vec4 glint_color : source_color = vec4(0.88, 0.97, 1.0, 1.0);

varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 base = COLOR;
	// Xanh nước: kênh lam cao hơn hẳn kênh đỏ. Cát và viền nâu thì ngược lại.
	float water = smoothstep(0.2, 0.4, base.b - base.r);
	float t = wind_time;
	// Các đường gợn mảnh nằm ngang, uốn lượn và trôi dần.
	float line = sin(world_pos.y * 0.16 + sin(world_pos.x * 0.035 - t * 1.3) * 1.8 + t * 0.8);
	// Chỉ hiện từng vùng (vùng này trôi theo gió) để không thành hoạ tiết đều tăm tắp.
	// Tốc độ trôi KHÔNG nhân sức gió: thời gian lớn dần nên hễ sức gió đổi là pha nhảy vọt.
	float patches = 0.5 + 0.5 * sin(world_pos.x * 0.021 + world_pos.y * 0.013 - t * 1.2)
		* sin(world_pos.x * 0.008 - world_pos.y * 0.02 + t * 0.5);
	float glint = smoothstep(0.8, 1.0, line) * smoothstep(0.35, 0.8, patches);
	COLOR.rgb = mix(base.rgb, glint_color.rgb, glint * water * (0.35 + 0.3 * wind_strength));
}

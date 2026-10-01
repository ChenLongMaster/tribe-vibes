shader_type canvas_item;
// Lay ngọn sprite theo gió, chân (mép dưới ảnh) đứng yên. Dùng chung cho cỏ, hoa,
// bụi, cây, ngọn lửa — chỉ khác độ lay `sway_amount`. Thời gian và sức gió do node
// Wind cập nhật mỗi frame, nên tạm dừng game là cây cỏ cũng đứng yên.

uniform float wind_time = 0.0;
uniform float wind_strength = 0.5;
// Độ lệch tối đa của mép trên ảnh, tính bằng px trong ảnh 2×.
uniform float sway_amount = 8.0;

void vertex() {
	vec2 world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	// Sóng gió đi từ trái sang phải: chỗ bên phải lay trễ hơn một chút.
	float wave = sin(wind_time * 2.0 - world_pos.x * 0.01 + world_pos.y * 0.003);
	// Từng luồng gió lớn chậm rãi lướt qua map.
	float gust = 0.5 + 0.5 * sin(wind_time * 0.6 - world_pos.x * 0.0025);
	// Lệch dương trung bình → cây cỏ hơi ngả xuôi chiều gió, không lắc đều hai bên.
	float bend = (0.4 + 0.6 * wave) * (0.5 + 0.5 * gust) * wind_strength;
	VERTEX.x += bend * sway_amount * (1.0 - UV.y);
}

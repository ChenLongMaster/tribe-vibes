class_name TestCase
extends RefCounted
## Lớp cơ sở cho test. Mọi hàm bắt đầu bằng `test_` sẽ được runner gọi.
## Hàm test có thể `await` (vd đợi một frame) nếu cần.

var failures: PackedStringArray = []
## Node runner — dùng khi test cần gắn scene vào cây hoặc đợi frame.
var host: Node


func check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func check_eq(actual: Variant, expected: Variant, message: String) -> void:
	if typeof(actual) != typeof(expected) or actual != expected:
		failures.append("%s — nhận '%s', cần '%s'" % [message, str(actual), str(expected)])

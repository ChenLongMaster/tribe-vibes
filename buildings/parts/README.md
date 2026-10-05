# Ráp đá và hàng rào trong Godot

## Xem bộ mảnh

Trong FileSystem, mở **buildings → parts → catalog.tscn**, chọn tab **2D**. Chọn một mảnh rồi bấm **F** để đưa khung nhìn tới nó. Đây là bảng mẫu; không cần sửa bảng mẫu để dùng mảnh.

- `stone_01.tscn`…`stone_08.tscn`: 8 dáng đá khác nhau, neo ở chân.
- `bamboo_post.tscn` / `wood_post.tscn`: cọc riêng; bản `_tied` có dây mây buộc.
- `bamboo_h_32.tscn`, `bamboo_h_64.tscn`: thanh rào ngang dài 32 / 64 px.
- `bamboo_v_32.tscn`, `bamboo_v_64.tscn`: thanh rào theo chiều sâu dọc màn hình. Được vẽ riêng, không xoay ảnh ngang.
- Các bản `wood_h_*` / `wood_v_*` tương tự, dày và có giằng chéo.

Mở **examples/fence_examples.tscn** để xem 3 kiểu đường bao ráp từ chính các mảnh này. Các ví dụ chỉ là trang trí để tham khảo thao tác.

## Dùng ở bất kỳ scene 2D nào

1. Mở **scene đích**, ví dụ bếp, kho hoặc scene riêng của bạn.
2. Tạo một **Node2D** tên `FenceBack`, `FenceFront` hoặc `Decoration` để gom mảnh. Chọn nhóm đó trong cây Scene.
3. Từ **FileSystem**, kéo file **.tscn của mảnh** vào vùng 2D hoặc vào nhóm trong cây Scene. Kéo `.tscn`, không kéo `.svg` nếu muốn giữ sẵn cỡ và neo.
4. Chọn node gốc của mảnh vừa thêm, dùng Move hoặc **Inspector → Transform → Position** để đặt. **Ctrl+D** nhân bản; **Ctrl+S** lưu scene đích.
5. Muốn dùng nguyên bộ rào đã ráp ở nhiều nơi: nhấp phải nhóm → **Save Branch as Scene…**, lưu vào thư mục của bạn rồi kéo scene mới đó vào các scene khác.

Mỗi lần kéo một `.tscn` là một instance riêng: thay Position/Scale của nó chỉ ảnh hưởng chỗ đó. Nếu mở và sửa file mảnh gốc, mọi nơi đang dùng mảnh đó sẽ nhận thay đổi. Không cần **Make Local** hoặc **Editable Children** để kéo/đổi cỡ instance.

## Nối thanh và cọc

- Thanh ngang dài 64: tâm thanh nằm giữa hai cọc. Ví dụ cọc tại `(0, 0)` và `(64, 0)` thì thanh tại `(32, 0)`. Đoạn 32 dùng cọc cách 32, thanh ở giữa.
- Thanh dọc dài 64: gốc thanh ở đầu gần. Ví dụ cọc tại `(0, -64)` và `(0, 0)` thì thanh tại `(0, 0)`. Bản 32 tương tự.
- Mỗi thanh có marker **JoinA / JoinB** chỉ hai chỗ đặt chân cọc. Tọa độ trên giả định Scale `(1, 1)`.
- Tại góc, cho hai thanh dùng chung một cọc. Không cần một hình góc riêng. Chừa cổng bằng cách bỏ một đoạn thanh và đá tại lối vào.
- Đặt đá **giữa các chân cọc**, có thể xê dịch nhẹ và xen kẽ dáng/cỡ. Đừng đặt chân cọc lên giữa viên đá.
- Giữ thanh ở Scale `(1, 1)` rồi nối thêm đoạn để dài hơn; tránh kéo giãn thanh. Đá có thể scale đều khoảng `0.55–1.0` theo cỡ công trình, không xoay cả sprite vì ánh sáng/góc nhìn sẽ sai.

## Thay rào trong bếp đang dùng

**Bếp cả ba cấp đã dùng bộ mảnh này.** Mở scene kitchen_1/2/3, bung FenceBack/FenceFront rồi chọn từng Stone/Bamboo/Wood để kéo, Ctrl+D nhân bản hoặc xoá mảnh. Nội thất bạn đã chỉnh vẫn giữ nguyên. Các bước ẩn Art dưới đây dành cho scene khác còn rào nguyên khối.

1. Lưu scene bếp hiện tại; có thể **Save As** một bản thử trước.
2. Mở nhóm `FenceBack` / `FenceFront`; chọn Sprite **Art** cũ và tắt **Visibility → Visible**. Không xoá nhóm cha hoặc đổi tên nhóm.
3. Kéo các mảnh mới làm **con của FenceBack / FenceFront**, rồi ráp theo đúng mép sân hiện có. Nhớ Position trong Inspector tính từ nhóm cha, không phải từ toàn scene.
4. Nếu rào che dân sai: bật **Ordering → Y Sort Enabled** trên nhóm; gốc mỗi mảnh phải ở chân. Không đặt Z Index tuỳ ý. Giữ hai nhóm của bếp như hiện tại; root bếp đã bật Y-sort.
5. Ctrl+S, chọn **KitchenLayout → Export menu / placement PNG**, chờ import rồi chạy lại game.

Hình mới sẽ được game render và xuất PNG cùng các bộ phận bếp. Bộ kit không tự sửa các scene bếp bạn đã chỉnh. Script `tools/gen_modular_art.py` chỉ sinh SVG; không ghi đè scene ráp tay.

## Giới hạn

Các mảnh là **hình trang trí**, không tự tạo va chạm, đường đi, công trình hay tài nguyên để nhặt. Ráp ở scene khác thì bố cục chỉ tồn tại ở nơi scene đó thực sự được game nạp. Giữ footprint và cổng bếp hiện tại; dời cổng hoặc rào chắn ngang lối cần sửa luật đi lại riêng.

Scale mảnh gốc mặc định `(1, 1)`; Sprite bên trong đã hiển thị ×0.5. Rào dựng thẳng theo hai trục sân, góc nhìn từ trên nằm trong hình. Cọc đứng thẳng; đá thấy mặt trên và hông phải, không có nền sân hình chữ nhật. File SVG không có chữ.

# Tự chỉnh bố cục bếp trong Godot

Mở project trong Godot, mở `kitchen_1.tscn`, `kitchen_2.tscn` hoặc `kitchen_3.tscn` ở thư mục này rồi chọn tab **2D**. Đây là scene game đang sử dụng, không phải bản phác.

## Kéo và đổi cỡ

1. Chọn **nhóm cha trong cây Scene** bên trái:
   - `CookingCanopy`: gian nấu, mái/cọc/nồi/dụng cụ, chỗ đứng nấu và cảnh báo.
   - `Serving`: quầy món, các bát trên quầy, điểm dân tới lấy món và vùng tránh.
   - `RoastFire`: giá quay, gà/lửa/khói, chỗ đứng người quay và vùng tránh.
   - `Dining0`, `Dining1`…: từng bộ chiếu/bàn/ghế, hai chỗ ngồi, mặt ghế và vùng tránh.
   - Mở `FenceBack` / `FenceFront`, chọn `Stone…`, `Bamboo…`, `Wood…` để kéo từng viên đá, cọc hoặc thanh rào. Đây là các instance của bộ mảnh dùng chung; Ctrl+D nhân bản mảnh.
2. Kéo nhóm bằng công cụ Move; hoặc sửa **Transform > Position** trong Inspector. Đổi **Transform > Scale** để tăng/giảm kích thước. Ví dụ `(1.1, 1.1)` lớn hơn 10%; `(0.9, 0.9)` nhỏ hơn 10%. Nên dùng scale dương và đổi đều hai chiều, khởi đầu khoảng 0.8–1.2.

   Pivot của gian nấu ở chân cọc trước, các nhóm khác ở chân vật: tăng cỡ sẽ vươn lên từ mặt đất, không lấy một điểm trống ngoài hình làm tâm.
3. Chọn root `KitchenLayout`, bật **Show Guides** để thấy lưới 4×3 và vùng tránh màu đỏ; bật **Show People** để thấy dân mẫu cỡ người lớn. Dân mẫu đứng để so tỉ lệ, không phải animation ngồi thật. Những hướng dẫn này chỉ hiện trong editor.
4. **Ctrl+S**, dừng ván đang chạy rồi chạy lại. Ván đã lưu cũng dùng bố cục mới; không cần mở ván mới.

Hình và điểm tương tác nằm chung nhóm nên cùng dịch/scale. Người thật giữ nguyên cỡ; vị trí hông/ngồi đọc mặt ghế mới. Nhịp quay/lửa, che khuất trước-sau, món trên quầy, cảnh báo và bóng mái vẫn chạy trong game.

## Đồng bộ menu và bóng đặt công trình

Sau khi chỉnh xong và lưu scene, chọn root, bấm **Export menu / placement PNG** trong Inspector. Nút xuất hình nguyên bếp vào `assets/art/buildings/kitchen_1.png` (hoặc cấp 2/3), nền trong suốt, đúng khung 512×552 và neo cũ. Godot cần một lúc để import PNG mới; chạy lại game để nạp hình mới. Lặp lại với mỗi cấp bạn sửa.

Game sống đọc scene trực tiếp. Menu/bóng khi đặt/móng đang xây đọc PNG được xuất; nếu chưa bấm Export thì chúng vẫn là hình của lần xuất trước. Script sinh SVG tạm không ghi đè scene hoặc PNG này.

Khung xám là giới hạn hình xuất. Nếu một phần hình vượt khung, nút xuất báo warning và không ghi đè hình trước; kéo/thu nhóm vào khung rồi xuất lại. Đây là giới hạn để giữ hợp đồng khung/neo hiện hành.

## Giữ các phần này

Rào cả ba cấp đã ráp bằng [bộ mảnh dùng chung](../parts/README.md). Các nhóm FenceBack/FenceFront không còn Sprite Art nguyên khối, bạn chỉnh từng instance bên trong. Giữ đường bao và cổng hiện tại.

- Giữ root tại Position `(0,0)`, Scale `(1,1)`. Root và Sprite con đã khoá để tránh chọn nhầm. Chỉnh nhóm nội thất hoặc instance mảnh rào thay vì mở khoá/kéo từng lớp mái hoặc từng Sprite. FenceBack/FenceFront giữ vị trí nhóm, không gom chọn toàn nhóm để bạn dễ chọn từng mảnh.
- Giữ hướng vẽ, **không xoay/mirror nhóm**; chân vật và hướng ngồi được thiết kế theo chiều hiện tại. Dùng Position và Scale dương.
- Giữ số bộ bàn/ghế, tên node và marker: chúng là hợp đồng chỗ 4/6/8 khách và 1/2/3 đầu bếp. Không đổi footprint/rào/cổng/lưới 64 px. Không scale cả sân để mở rộng diện tích đặt.
- Vùng đỏ không nên chồng lên điểm người đứng/ngồi. Chừa lối từ cổng đến quầy, giá quay và bàn. Scale quá lớn hoặc dồn đồ quá sát vẫn có thể làm bố cục chật; xem thử lúc đủ người ăn/nấu.
- Không chạy lại script bootstrap trong `build/…/create_scenes.gd`: đó là công cụ chuyển đổi một lần, sẽ khôi phục bố cục gốc.

Toạ độ scene là pixel hiển thị. Không cần sửa `data/kitchen_layout.gd` hoặc số trong Python để dời vật nữa. `tools/gen_building_art.py` chỉ sinh nét/hình tạm theo hợp đồng cũ; các SVG ghế riêng `seating_*` phục vụ scene mới.

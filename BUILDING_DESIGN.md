# BUILDING_DESIGN — Thiết kế công trình

> Hướng được người dùng duyệt ngày **2026-10-05**. Đọc file này **trước khi vẽ hoặc sửa hình công trình, ráp scene, bố trí nội thất/điểm tương tác, hoặc tối ưu render công trình**.
>
> [GAME_DESIGN.md](GAME_DESIGN.md) là nguồn thiết kế game chung: luật, chức năng, footprint, sức chứa và cân bằng. File này đặc tả hướng hình ảnh và cách dựng công trình đã chốt. [ASSET_SPEC.md](ASSET_SPEC.md) giữ hợp đồng từng asset: tên, khung, neo và tỉ lệ. Các mục lịch sử/phác thảo trong GAME_DESIGN không thay thế hướng hiện hành ở đây.
>
> Đây là spec để thực hiện các việc được giao, không tự mở thêm phạm vi. **Không tự git commit / git push.**

## 1. Chín nguyên tắc đã chốt

### 1.1 Công trình là không gian dân sử dụng được

Công trình phải tạo cảm giác là một vật thể trên đất và một nơi dân có thể sử dụng, không giống một tấm ảnh dán lên map. Dân có chỗ đứng/ngồi và animation tương ứng với chức năng: chui vào lều ngủ, đứng bên nồi nấu, quay xiên, lấy món, ngồi ăn…

Với khu mở như bếp, nhìn được dân ở giữa các bộ phận. Với lều kín, cửa và lớp che phải làm rõ việc dân đi vào rồi khuất trong lều. Không cần thấy bên trong mọi công trình; cách thể hiện phải phù hợp chức năng.

### 1.2 Ráp bằng bộ phận dùng chung

Ưu tiên các mảnh có thể dùng lại: viên đá, cọc, đoạn rào, mái, bàn, ghế, dụng cụ và đồ trang trí. Dựng chúng thành các instance scene nhỏ, ghép trong scene công trình. Người dùng phải tự kéo vị trí, đổi cỡ, nhân bản hoặc xoá mảnh trong Godot được.

Hình dạng/góc nhìn/vật liệu của mảnh do art quyết định; bố cục cuối do scene quyết định. Không vẽ lại cả ảnh khi chỉ cần đổi chỗ một vật. Không ép tách mọi nét nhỏ thành node riêng: một vật hoặc một bộ phận cần chỉnh độc lập là đơn vị phù hợp. Ví dụ một bàn và ghế có thể là nhóm, mái/cọc/nồi cùng thuộc nhóm gian nấu.

### 1.3 Góc nhìn đồng bộ và có chiều sâu

- Game vẫn **2D**, lưới vuông **64 px**, camera/map giữ hệ hiện hành. Hướng nhìn nằm trong hình, không đổi camera hoặc xoay lưới để sửa art.
- Cảm giác 3/4 từ trên xuống như Prehistoric Tribes: mặt trên/mái rộng, cạnh bên và chiều sâu đọc được, mặt đứng co vừa đủ. Mốc thị giác khoảng 45–60°, không ép phép chiếu isometric chuẩn.
- Lều ngủ và gian nấu hướng **trước-phải**. Cửa, mái và chân cùng theo một khối, không chỉ xiên một đường mái trên một mặt cửa chính diện.
- **Không xoay mọi vật 45°.** Sân bếp là chữ nhật theo hai trục màn hình; gian nấu chếch phải; bàn/chiếu theo trục sân, có mặt trên và độ cao. Rào có bản ngang và bản dọc theo chiều sâu được vẽ riêng, không lấy ảnh ngang xoay 90°.
- Cột đứng thẳng. Vật tự nhiên như đá dùng phân mảng mặt trên/hông và che khuất để tạo khối. Dùng bóng sát chân, mép/chân bàn và lớp trước–sau; không dùng một hình đối xứng phẳng để thay cho chiều sâu.

### 1.4 Tiền sử dễ thương, gợi nét Việt nhẹ

Hình mềm, bo tròn, màu ấm và viền nâu **#4E342E** theo bảng màu ASSET_SPEC. Vật liệu thủ công có vân, nếp, nút buộc, chỗ vá hoặc sờn vừa đủ để đọc ở cỡ chơi thật.

Tre/nứa, dây mây, gỗ, cỏ/rơm/lá, đá và đất nung dùng theo chức năng. Da thú là vật liệu chính của lều ngủ; không bắt mọi công trình dùng da hoặc biến thành cùng một kiểu nhà. Hoa văn chim Lạc, mặt trời, răng cưa/vòng tròn cách điệu chỉ gợi nhẹ. Không dùng biểu tượng đặc trưng văn hoá khác để thay cho nét Việt.

Lấy cảm hứng góc nhìn, tỉ lệ và không khí của game gốc; không chép hình/texture/logo, không ép tái dựng đúng một giai đoạn lịch sử. **Không vẽ chữ vào asset**; chữ UI đi qua Loc như GAME_DESIGN quy định.

### 1.5 Các cấp tiến bộ rõ bằng thiết kế

Cấp thấp nhỏ/đơn sơ/cũ hơn; cấp giữa chắc và gọn hơn; cấp cao hoàn thiện, đầy đặn và có trang trí hơn. Phân biệt bằng vật liệu, dáng, độ hoàn thiện, dụng cụ và bố trí sử dụng, không chỉ tăng scale.

Giữ họ vật liệu và chức năng của từng công trình. Không tự đổi số ghế, sức chứa, footprint hoặc luật chỉ để làm hình lớn hơn. Có thể sân nhìn nhỏ hơn ở cấp thấp để tránh quá trống, nhưng diện tích đặt vẫn theo dữ liệu game.

Ngoại lệ hiện hành: **mái gian nấu bếp giữ mẫu cũ đã duyệt**; thử kiến trúc mái khác đang hoãn. Không khôi phục bản thử bị người dùng bỏ qua.

### 1.6 Bố cục tự nhiên, có khoảng trống sử dụng

Chừa khe đất nhỏ giữa **chân** cọc/bàn/gian nấu và đá/rào. Mái được phủ lên đá phía sau một cách tự nhiên; không dịch nguyên gian nấu ra xa chỉ để lộ đá sau mái. Bàn, ghế, quầy và giá quay có khoảng trống đủ cho dân đứng/ngồi/di chuyển.

Đá méo nhẹ, đỉnh bè/bo mềm; tránh các viên nhọn như tam giác. Xen kẽ dáng/cỡ và lệch vị trí nhẹ để đường bao không như máy xếp. **Chân cọc ở khe giữa đá**, không cắm vào mặt đá. Thanh rào chia khoang và dùng chung cọc ở góc. Giữ cổng và lối tới các vị trí sử dụng.

Không lấp sân bằng chi tiết chỉ để hết trống. Chỗ trống phải có chủ đích; thêm vật phù hợp chức năng và giữ các hoạt động nhìn rõ.

### 1.7 Hoà vào map, không có nền ảnh hình chữ nhật

Asset có nền trong suốt. Chân vật/bóng tiếp xúc nằm trên đất của map; không có tấm nền màu đặc bao quanh công trình làm nó giống ảnh dán.

Đất dọn cỏ do hệ map/sân hiện hành tạo, mép hữu cơ và lan vừa đủ. Công trình gần nhau có thể nối sân tự nhiên. Không tự tăng vùng đất hoặc che hết cỏ một vòng rộng chỉ để che lỗi bố cục.

Footprint có thể là chữ nhật trên lưới nhưng đường mép đất, đá và hình vật không cần thành một khung đều tuyệt đối. Móng giữ bố cục chữ nhật nhìn từ trên, không xoay xiên ngang; cọc móng khớp bốn góc.

### 1.8 Hình và điểm tương tác cùng đi theo bộ phận

Nhóm bàn chứa hình bàn/ghế, điểm hai người ngồi, mặt ghế và vùng tránh. Nhóm gian nấu chứa các lớp hình, điểm đứng nấu và cảnh báo. Quầy chứa điểm lấy món; giá quay chứa lửa/gà/khói và điểm người quay. Khi kéo/scale nhóm, các điểm đó phải đi cùng.

Dân giữ cỡ và rig riêng; không scale dân theo bàn. Hông khớp mặt ngồi, tay khớp việc đang làm, chân/cột nối đất. Che khuất/Y-sort theo chân vật, không theo tâm khung ảnh. Icon cảnh báo ở mái; phản hồi chọn nhẹ, không dùng vòng ellipse lớn làm lệch cảm giác footprint.

Mảnh trang trí không tự có collision hoặc trở thành một tài nguyên. Chỉnh hình rào không tự đổi đường đi. Giữ tên/số marker tương tác, footprint và cổng đã chốt; đổi các phần này cần thực hiện như thay đổi thiết kế/core được giao, không lẫn vào sửa art.

### 1.9 Chỉnh dễ trước, tối ưu phần tĩnh sau

Scene ráp mảnh là bản nguồn để thiết kế. Nếu đo hiệu năng thấy cần, có thể xuất/gộp những lớp tĩnh như đá và rào thành ảnh trong suốt để giảm số node/lượt vẽ. Giữ riêng những phần cần animation hoặc che dân đúng chiều sâu; không gộp cả công trình rồi vẽ đè lên dân.

**Hiện chưa triển khai tự gộp rào lúc chạy.** Bếp đang render các mảnh thật. PNG xuất hiện tại dùng cho menu/bóng đặt/móng đang xây, không thay thế render bếp sống. Không ghi tài liệu hoặc báo cáo như thể bước tối ưu đã tồn tại. Đo trên thiết bị đích trước khi quyết định tối ưu; số node không đồng nghĩa trực tiếp với số draw call.

## 2. Mẫu công trình hiện hành

| Loại | Hướng đã chốt | Ba cấp / hoạt động |
|---|---|---|
| Lều ngủ | Da thú thuôn nhọn, phủ cỏ/rơm, khung tre/mây, cửa trước-phải; footprint 2×2 | Cấp1 nhỏ/cũ/vá/cỏ thưa; cấp2 lớn hơn/lành/gọn; cấp3 lớn nhất, cỏ/rơm và hoa văn Lạc Việt nhẹ. Chui vào ngủ, khuất trong lều; 2/3/4 chỗ ngủ theo dữ liệu. |
| Bếp | Sân mở hình chữ nhật, footprint **4×3**; gian nấu trên-trái chếch trước-phải; quầy dọc gần rào trái; bàn/chiếu dọc, dân ngồi hai bên trái–phải | Cấp1 đá và 2 chiếu/4 khách; cấp2 đá + tre, 3 bàn đá tam giác, ngồi khúc gỗ/6 khách; cấp3 đá + gỗ, 4 bàn gỗ và ghế/8 khách. 1/2/3 đầu bếp; người thứ hai ở giá quay, chỉ còn một người thì về nồi chính. |

Vị trí/cỡ hiện hành của bếp nằm trong scene người dùng đã chỉnh, không lấy các số bố cục lịch sử để sinh đè lên chúng. Quầy/gian nấu giữ khe đất ở chân với rào; mái có thể phủ rào. Giá quay và hai hàng bàn phải chừa khoảng trống hoạt động.

Các công trình khác áp dụng nguyên tắc chung khi được giao thiết kế; chưa mặc định đã được chuyển thành bộ scene ráp mảnh tương tự bếp.

## 3. Nguồn dữ liệu và nơi sửa

| Nội dung | Nơi đọc / sửa |
|---|---|
| Luật, chức năng, footprint, sức chứa | GAME_DESIGN mục9.3; `data/buildings.gd`, `data/balance.gd` |
| Hướng hình ảnh và cách dựng | File này; GAME_DESIGN mục7 giữ chỉ dẫn và các mốc lịch sử |
| Tên file, frame, pivot, bảng màu | ASSET_SPEC; `data/art_specs.gd` phải khớp |
| Bố cục bếp trong game | `buildings/kitchen_layouts/kitchen_1.tscn`…`kitchen_3.tscn` |
| Cách chỉnh bếp bằng Godot | [buildings/kitchen_layouts/README.md](buildings/kitchen_layouts/README.md) |
| Mảnh dùng chung và cách ráp | [buildings/parts/README.md](buildings/parts/README.md); `catalog.tscn`, `examples/fence_examples.tscn` |
| Nét hình SVG tạm | `assets/placeholder/`; generator trong `tools/` |
| Art thật thay thế | `assets/art/`, cùng key ArtLibrary; ưu tiên hơn placeholder |
| Quyết định và kiểm tra mỗi đợt | DEVLOG; ảnh/script QA ở `build/` có `.gdignore` |

Mọi hình vẽ **2×**, hiển thị **×0.5**. Giữ tên file/khung/neo hiện hành; nếu thay khung hoặc neo phải sửa cả ASSET_SPEC và ArtSpecs, cùng các marker/rig liên quan. Footprint là diện tích đặt trên lưới, không suy ra từ kích thước sprite.

`tools/gen_modular_art.py` sinh SVG mảnh, **không ghi lại scene ráp tay**. Không chạy lại bootstrap ráp scene để sửa hình nếu nó sẽ xoá bố cục người dùng. Cất bản trước sửa và bảo vệ những nhóm ngoài phạm vi được giao.

## 4. Quy trình sửa một công trình

1. Đọc AGENTS mục0, DEVLOG mới nhất, file này, hợp đồng asset và scene/dữ liệu công trình cần sửa. Xác định phần được giao và trạng thái đã duyệt/đang hoãn.
2. Giữ hoặc sao lưu bố cục người dùng. Chọn mảnh dùng lại trước; chỉ vẽ thêm khi thiếu dáng/vật liệu/chức năng.
3. Ráp trong scene với gốc ở chân; dùng Position và Scale dương. Đổi cỡ đều để giữ nét; nối thêm đoạn rào thay kéo dài ảnh. Không xoay/mirror toàn sprite để giả góc nhìn khác.
4. Canh bằng dân mẫu, lưới, vùng tránh và trạng thái đủ người dùng công trình. Sửa hình và marker/vùng tránh cùng nhóm khi cần; giữ lối vào và các giới hạn của GAME_DESIGN.
5. Ctrl+S. Với bếp: root **Export menu / placement PNG**, đợi import, chạy lại game. Khi dùng ở scene khác, phải bảo đảm game thực sự nạp scene đó; thêm mảnh vào một scene mẫu không tự áp dụng vào ván.
6. Kiểm tra import/runtime và các test liên quan theo AGENTS; dùng strict khi sửa code. Chụp rồi **tự mở ảnh**, xem cỡ chơi thật và zoom, trước/sau, đủ người ăn/nấu/ngủ, cùng trạng thái xây/nâng cấp/chọn có liên quan.
7. Ghi DEVLOG; cập nhật spec/hợp đồng nếu quyết định thay đổi. Dừng đúng phạm vi được giao để người dùng duyệt.

## 5. Duy trì spec qua các phiên

- Phiên đụng tới thiết kế công trình phải đọc file này trước khi triển khai, kể cả chỉ đổi vị trí/cỡ hoặc tối ưu render.
- GAME_DESIGN giữ quyết định tổng quát và link tới đây. Khi có hướng mới được duyệt, cập nhật GAME_DESIGN và phần chi tiết ở đây trong cùng đợt; đồng bộ GAME_DESIGN sang **cả AGENTS lẫn CLAUDE**, giữ phụ lục riêng.
- ASSET_SPEC chỉ cập nhật hợp đồng/tình trạng asset cần thiết; DEVLOG ghi việc đã làm. Phân biệt rõ **đã áp dụng**, **bản thử**, **đang hoãn** và **chưa triển khai**.
- Chỉ dẫn mới của người dùng ưu tiên hơn tài liệu cũ. Không tự quay lại góc nhìn/vật liệu hoặc bố cục cũ vì một mục lịch sử còn trong tài liệu.

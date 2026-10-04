# DEVLOG — Tribe Vibes (Bộ Lạc Chill)

Mỗi đợt một mục: đã làm gì, chọn gì và vì sao. Mục mới nhất ở trên cùng.

---

## Chốt tài liệu art đã áp dụng và style hiện hành (2026-10-04)

- Theo yêu cầu người dùng: GAME_DESIGN mục7 thêm bảng trạng thái đang dùng cho lều/móng/nhân vật01/tài nguyên/bếp/phản hồi trên đầu, ghi rõ nhóm chưa vẽ lại và nguồn ảnh chuẩn. Sửa ghi chú bụi dâu v7 còn “chờ duyệt” thành đã đồng ý/đang dùng; các phác bếp cũ giữ làm lịch sử.
- Ghi lại style tiền sử thủ công dễ thương, màu ấm/viền nâu/bo tròn, góc3/4 cao có chiều sâu ngang, lều hướng trước-phải và nét Việt gợi nhẹ. Giữ các ngoại lệ đã duyệt: bụi dâu tán mềm/quả đỏ nhỏ nhiều riêng lẻ; bếp sân chính diện/khu nấu chếch phải/bàn dọc/người ngồi hai bên. Bụi mới sinh đầy100%, không sửa lượng trong save.
- Đồng bộ GAME_DESIGN sang CLAUDE/AGENTS giữ prefix/phụ lục; ASSET_SPEC thêm trạng thái tài nguyên/style và sửa ghi chú icon nồi trên đầu đã lỗi thời. Chỉ cập nhật tài liệu, không thay asset/code/cân bằng, không commit/push.
- Kiểm tra: bản thiết kế trong CLAUDE/AGENTS khớp GAME_DESIGN, ảnh tham chiếu tồn tại; import và runtime600 frame sạch. Không chạy lại bộ test84 đã qua ở đợt bỏ icon vì lần này chỉ sửa Markdown.
- Cách xem: đọc mục7 GAME_DESIGN và mục “Tài nguyên đã áp dụng và chuẩn style hiện hành” ASSET_SPEC. Hạn chế: nhóm chưa vẽ lại vẫn giữ hình cũ; không có số mới cần chỉnh.

---

## Bỏ icon công việc thường trực trên đầu dân (2026-10-04)

- Theo yêu cầu màn hình thoáng hơn: Overhead không tạo sprite icon việc, không nghe task_changed để vẽ icon và không chạy hiệu ứng nhún của icon. Giữ cảnh báo chỉ số thấp, bong bóng nghĩ/nói, biển, Zzz, tim và sao khi ngất. Giữ activity_icon cho bảng nhóm và activity_key/args cho bảng thông tin; không đổi AI, task hay animation.
- GAME_DESIGN cập nhật mục2/5.2/6.2, đồng bộ CLAUDE/AGENTS và giữ nguyên phụ lục. Sửa mô tả test đình công để phản ánh icon bảng nhóm. Không đổi SVG/neo hay thông số cân bằng.
- Ảnh trước: build/art-review/2026-10-04/kitchen-live-v1/after/kitchen_levels.png. Ảnh sau: build/art-review/2026-10-04/no-work-icons/after/kitchen_levels.png. Tự mở cả hai so sánh; live scene dùng cùng bố cục và người nấu/ăn thật, giữ người tại khoảnh khắc hoạt động để so đủ chỗ như đợt trước.
- Kiểm tra: import sạch; toàn bộ84/84 test strict qua, runtime600 frame strict và cảnh chụp thật sạch. override.cfg đã xoá; git diff --check qua. Log/scene QA nằm trong build/art-review/2026-10-04/no-work-icons.
- Cách thử: giao dân hái/chặt/nấu hoặc chờ họ ăn; không còn icon việc trên đầu, chọn dân xem dòng đang làm trong bảng thông tin. Hạn chế: icon cảnh báo nhu cầu và bong bóng vẫn có thể xuất hiện khi nhiều người đói; đây là phản hồi đang giữ theo thiết kế. Không có số mới cần chỉnh. Không commit/push.

---

## Áp dụng bếp v7 vào game — Sân3×2 có dân nấu/ngồi ăn (2026-10-04)

- Theo người dùng duyệt mẫu v7 và yêu cầu áp dụng: thay cả kitchen_1/2/3 bằng hình đã duyệt, footprint3×2 ở mọi cấp; sân76/89/100%, mái nấu chéo phải52/60/67%, chiếu/bàn dọc. Cấp1 đá/hai chiếu/4 khách; cấp2 đá+tre mảnh/ba bàn đá tam giác/6 khách; cấp3 đá+gỗ chắc/bốn bàn gỗ2×2/8 khách. Giữ costs/build_seconds/cook_seconds/staff1–2–3/stock_capacity6–10–16/capacityFOOD30–60–120.
- Khung384×336/2×, sân rawy64→320, neo raw192,296 = (0.5,37/42). ArtSpecs/ASSET_SPEC đồng bộ; móng dùng foundation_3x2 đã có. tools/gen_building_art.py gọi helper tự chứa tools/kitchen_art.py, không đọc build. Thêm36 lớp SVG cùng khung/neo và props/cooking_spoon20×80/neo10,6. So với baseline đầu đợt, chỉ ba SVG bếp cũ đổi; tất cả hình lều/móng/tài nguyên/nhân vật khác giữ hash. Soát XML,36 lớp khớp hình học v7, tái sinh deterministic toàn bộ asset.
- KitchenInterior tách hình theo y-sort cùng Entities: sân dưới người, mái che đầu bếp, cọc/rào gần che đúng, từng bàn riêng. Nguồn bóng chỉ mái (sân không đổ bóng cao), warning ở mái trên-trái; món chín bày tối đa6 bát nhỏ trên quầy dưới-trái, số dự trữ thật trên panel. Dân vẫn scale game0.65; không lấy scale nhỏ hơn của người phác. Đầu bếp cầm muôi thay icon nồi; vị trí1/2/3 thợ giãn trong khu nấu.
- TaskCook/TaskEat dùng vị trí nấu/ghế có giữ chỗ; khách qua cổng, lấy đúng một món ở quầy, tránh bàn tới ghế trái/phải, ngồi ăn rồi ra cổng. Bếp đầy ghế tìm nguồn ăn khác theo luật cũ; chưa có hàng chờ riêng. AStar thế giới vẫn chặn footprint, tuyến nội thất riêng tránh bàn/quầy; path_origin tại cổng cho người ở trong sân để lệnh mới không bị từ chối vì ô đang đứng bị chặn. Đặt công trình không bịt cổng bếp. Lệnh mới khi đang ăn vẫn chờ ăn xong; task bị ngắt thật trả ghế. Nâng cấp điều chỉnh điểm bàn/nấu và giữ phần đang làm. Panel thêm số chỗ ăn đã giữ, chữ qua Loc/CSV. Không đổi luật nhu cầu/nấu/AI chọn việc khác.
- SaveGame format8 do bếp2×2→3×2 có thể đè nhà bên cạnh trong save cũ; format7 không tải, không xoá file cũ. Save format8 roundtrip giữ cấp,footprint,stock/job; ghế/vị trí task tạm không lưu. Lưu khi đang trong sân thì tải lại người ra ô trống theo cơ chế restore hiện có.
- GAME_DESIGN ghi trạng thái đã triển khai ở mục7 và hàng Bếp mục9.3, đồng bộ CLAUDE/AGENTS giữ phụ lục; ASSET_SPEC ghi bộ lớp/neo/đồ cầm và đánh dấu các mẫu cũ là lịch sử.
- Kiểm tra: import sạch; toàn bộ84/84 test thường và84/84 strict; runtime600 frame thường/strict sạch; strict live scene sạch. override.cfg đã xoá. Thêm4 test về dung lượng4/6/8, mỗi ghế có đường từ quầy, cổng không bị xây chặn, ăn xong trả ghế/lệnh mới, nâng cấp có khách/đầu bếp, ngắt task và save/load. Warning spawn ô chặn ở test_boot_loads_mode là test cũ cố ý; Loc thông báo thiếu en dùng vi. Đã sửa lỗi test dùng uid sau free rồi chạy lại sạch (runner không tự coi SCRIPT ERROR là FAIL, nên đã soát log).
- Chụp chuẩn seed42/buildings/jobs/wait40/speed4 trong build/art-review/2026-10-04/kitchen-live-v1/after; tự mở levels.png/village_zoom_1.png/construction.png/work.png. wait40 đã xây xong, chụp thêm construction-early/wait5/speed1 và tự mở construction.png để xem móng3×2/thợ khuân. live.gd dựng World thật seed42, dùng Commands/TaskCook/TaskEat, chờ người tự đi vào/nấu/ngồi; giữ từng người tại khoảnh khắc đó để so đủ4/6/8 khách và1/2/3 thợ, không phải ảnh mọi người tự đồng thời ăn trong ván thường. Đã tự mở kitchen_1/2/3 và kitchen_levels.png, chỉnh lớp mái/muôi/vị trí thợ rồi chụp lại. audit.py/audit.json và mọi script/log/ảnh kiểm tra trong build.
- Trước: build/art-review/2026-10-04/kitchen-foundation-v1/after/village_zoom_1.png và board.png (bếp đang chơi trước đợt này); mẫu duyệt: kitchen-compound-v7-vertical/levels.png. Sau: kitchen-live-v1/after/kitchen_levels.png (cấp1→3 trái→phải), village_zoom_1.png; construction-early/construction.png. Cách thử: godot --path . -- --seed=42; bấm Xây→Bếp, đặt sáu ô trống/cổng thông, chọn dân click phải móng để xây; có thức ăn thô thì giao người vào bếp nấu, dân đói tự vào quầy/ghế; nâng cấp để xem thêm bàn/rào/dụng cụ. live.tscn trong thư mục QA dựng lại ảnh đủ ghế.
- Hạn chế: save cũ format7 không tương thích; chưa có xếp hàng trước cổng; quầy chỉ bày6 bát đại diện lượng, panel giữ số chính xác. Cỡ bếp/nội thất/nhân vật theo mẫu đã chốt, icon nhu cầu/việc có thể hơi dày khi đầy8 khách và3 thợ. Số có thể tinh chỉnh: sân76/89/100%, mái52/60/67%, khoảng cách ghế/thợ và vị trí che khuất; giữ footprint6ô và trần8 khách. Dừng ở bếp, không vẽ thêm công trình, không commit/push.

---

## Chiếu/bàn ăn dọc, khu nấu nâng cấp rõ — Phác v7 (2026-10-04)

- Theo phản hồi đã duyệt bố cục v6: đổi chiếu/bàn ăn sang trục dài dọc màn hình, giữ người ngồi trái–phải. Vẽ lại mặt trên/viền/mặt đứng/chân bàn (không xoay cả sprite90°); hai phần thức ăn trên/dưới trên mỗi chiếu/bàn. Giữ bàn bày món dưới-trái riêng, lối vào và tam giác/2×2. Dời hàng chỗ ăn gần lên17px và bàn giữa tam giác lên8px ở file2× để chân bàn dọc không sát rào.
- Khu nấu tăng rõ cỡ/dáng/độ hoàn thiện và đồ nghề: cấp1 mái nhỏ thưa/sờn, tre và một nồi/cán khuấy; cấp2 mái lớn chắc hơn, tre buộc, muôi/trở đồ tre treo, chum, cối đất/chày gỗ; cấp3 mái rộng nhiều lớp/tua cỏ, khung gỗ dày, quầy chuẩn bị, bếp/nồi phụ, giàn muôi/rây đan, gùi, mặt trời nhỏ. Giữ hướng chếch phải và khung bốn chân; nồi/cán khuấy/người nấu dịch theo cỡ phần nấu.
- Mẫu/script trong build/art-review/2026-10-04/kitchen-compound-v7-vertical; extend.py dựng generator từ v6 rồi draw.py xuất hình. Khung384×336/2×, footprint3×2 không đổi, sân76/89/100%, phần nấu52/60/67%,4/6/8người. Tỉ lệ dân chung cho cả ba cấp, rig game không đổi. Giữ bản v6 để so sánh.
- Tự mở levels.png, layout.png và footprint.png: mặt bàn/chiếu dọc rõ, người vẫn ở hai bên, góc mái đúng hướng, đồ nấu/cỡ mái tăng và khu ăn không bị thêm bàn. Import/runtime600 frame thường sạch; strict preview/runtime sạch, override.cfg đã xoá. Soát37 SVG XML/khung, số chỗ2/3/4 và174SVG game giữ hash. Không chạy lại bộ80test đã qua ởv1 vì chỉ thay cảnh phác/tài liệu, không sửa core hoặc art đang dùng.
- GAME_DESIGN ghi quy tắc bàn dọc/khu nấu nâng cấp, đồng bộ CLAUDE/AGENTS giữ phụ lục, ASSET_SPEC ghi mẫu mới nhất. Bếp đang chơi vẫn2×2/art cũ, chưa đổi ArtSpecs/neo/AI/footprint code. Đây là ảnh scene dựng sẵn, chưa phải hành vi tự nấu/chọn ghế/lấy món.
- Trước: kitchen-compound-v6-six-cells/levels.png; sau: kitchen-compound-v7-vertical/levels.png, layout.png, footprint.png. Cách xem: mở ảnh hoặc godot --audio-driver Dummy --path . res://build/art-review/2026-10-04/kitchen-compound-v7-vertical/preview.tscn.
- Số nên chỉnh: độ dài/rộng mặt bàn dọc, khoảng trống giữa hàng, cỡ mái52/60/67% và mức chi tiết dụng cụ khi thu xa. Giữ6ô và tối đa8người. Dừng ở mẫu chờ duyệt, không commit/push.

---

## Bếp6ô, sân lớn dần và người ăn ngồi ngang — Phác v6 (2026-10-04)

- Theo ba sơ đồ đính chính mới nhất: thiết kế cả ba cấp chiếm3×2 =6ô, tối đa4 chỗ ăn/8 người; cấp1 hai chiếu/4 người, cấp2 ba bàn đá/6 người xếp tam giác (hai trái trên/dưới, một phải giữa), cấp3 bốn bàn gỗ/8 người xếp2×2. Người ăn ở hai bên trái–phải từng chỗ và cầm món quay vào giữa, không ngồi trên–dưới. Bàn bày thức ăn riêng dưới-trái, cổng trước cạnh bàn, lối bên phải bàn bày nối vào khu ăn.
- Cấp1 sân/nội thất thu76%, cấp2 89%, cấp3 100% quanh cùng tâm; giữ vùng6ô như nhau, không tăng footprint theo cấp. Vòng đá/rào tre mảnh/rào gỗ chắc giữ phân cấp đã yêu cầu, giảm chiều cao rào gỗ xuống28px ở file2× để không che gần hết người. Thêm chum/gùi/mặt trời nhỏ; bàn bày riêng không tính vào số bàn/chỗ ăn.
- Khu nấu trên-trái đảo sang phải theo phản hồi; mái/hông/cọc/nồi cùng khối, không xoay camera/lưới. Lỗi v4 chân bị mái/nồi che đã sửa: khung bốn cọc, kéo phần chân lộ ra, nồi dịch khỏi cọc gần và cọc gần tách lớp trước nồi. Cán khuấy hướng về người nấu. Đã tự mở ảnh có người và ảnh trống để soi chân/che khuất.
- Mẫu/script tại build/art-review/2026-10-04/kitchen-compound-v6-six-cells; khung384×336 ở2×, vùng sân384×256 từy64. Ảnhlevels.png, layout.png, footprint.png (có lưới QA6ô). Người phác cùng tỉ lệ ở ba cấp, chỉ sân/nội thất thu; rig game không đổi. Bảnv5 đang dựng trước lời đính chính đã bỏ, không xuất hình/chốt thiết kế.
- Không sửa asset/AI/map/footprint code:174 SVG game khớp baseline, bếp đang chơi vẫn2×2. GAME_DESIGN cập nhật thiết kế mục7 và hàng bếp mục9.3 thành3×2/4–6–8người (ghi rõ chưa triển khai), đồng bộ CLAUDE/AGENTS giữ phụ lục; ASSET_SPEC ghi riêng khung phác và lịch sử bị thay thế. Cảnh mẫu không đăng ký ArtLibrary/ArtSpecs/neo mới.
- Kiểm tra: import sạch, runtime600 frame thường và strict sạch, strict preview sạch, override.cfg đã xoá; SVG XML/khung và dữ liệu2/3/4chỗ→4/6/8người hợp lệ. Không chạy lại bộ80test đã qua ởv1 vì chỉ sửa cảnh phác/tài liệu, không thay core/art đang dùng. Tự mở levels/layout/footprint và chỉnh rào/cọc để đọc rõ hơn.
- Trước: kitchen-compound-v4-tiers/levels.png; sau: kitchen-compound-v6-six-cells/levels.png, layout.png, footprint.png. Cách xem: mở ảnh hoặc godot --audio-driver Dummy --path . res://build/art-review/2026-10-04/kitchen-compound-v6-six-cells/preview.tscn. Hạn chế: người dựng sẵn, chưa có AI đi vào/chọn ghế/lấy món hoặc đổi bếp trong ván chơi.
- Số nên chỉnh: tỉ lệ sân76/89/100%, khoảng cách ghế trái/phải, độ rộng cổng76px ở2×, độ cao rào gỗ28px ở2×; footprint3×2 và tối đa8 người là yêu cầu cố định. Dừng ở bản phác cho người dùng duyệt, không commit/push.

---

## Phân cấp khu bếp, mái nấu chéo và khu ăn thẳng — Phác v4 (2026-10-04)

- Người dùng đồng ý layout chữ nhật, yêu cầu sửa phân cấp và góc mái nấu. Cấp1 chỉ vòng đá tự nhiên (lệch cỡ/màu), hai chiếu mây nhỏ cho bốn người ngồi đất, không bàn/rào. Cấp2 thêm rào tre mảnh với cọc/đốt/buộc hơi lệch, ba bàn đá. Cấp3 rào gỗ dày chắc có giằng chéo, bốn bàn gỗ. Giữ cổng trước và đường giữa nấu/ăn.
- Khu nấu góc trên-trái dựng chéo trước-phải như lều, cả mái/mặt hông/khung/nồi theo khối, không xoay toàn bộ sprite và không còn chính diện v3. Khu ăn vẫn cạnh ngang chính diện; chiếu/bàn không bị nghiêng theo mái. Dùng phần bếp có chiều sâu ngang/dọc của bản v1 làm nền, bổ sung trang trí theo cấp: chiếu/sờn/bếp đơn sơ; tre buộc/chum đất; mái buộc chắc/gùi mây/mặt trời nhỏ gợi Lạc Việt. Không sao chép art game tham khảo.
- Mẫu/script nằm riêng tại build/art-review/2026-10-04/kitchen-compound-v4-tiers. Giữ khung512×448/2×, sân4×3 đang thử; không sửa bếp hiện hành2×2/ArtSpecs/asset/gameplay/AI.174 SVG game khớp baseline. Số người ăn cấp2–3 chưa quyết định từ số bàn; trong ảnh đặt một người mỗi bàn để đọc bố cục, riêng cấp1 thể hiện đủ bốn người.
- Import sạch; strict preview và runtime600 frame sạch, override.cfg đã xoá. Lỗi gán Array sang Array[Vector2] trong script phác lần đầu đã sửa bằng assign() rồi chạy lại sạch. Tự mở levels.png và layout.png, dời hàng bàn gần cấp3 lên20px ở file2× để chừa chân người khỏi rào. Soát XML/khung/hash; không chạy lại bộ80 test đã qua ở v1 vì không thay core và hình đang dùng trong game.
- Trước: kitchen-compound-v3-rectangle/levels.png; sau: kitchen-compound-v4-tiers/levels.png và layout.png. Cách xem: mở hai ảnh hoặc godot --audio-driver Dummy --path . res://build/art-review/2026-10-04/kitchen-compound-v4-tiers/preview.tscn. GAME_DESIGN ghi yêu cầu mới nhất, đồng bộ CLAUDE/AGENTS giữ phụ lục, cập nhật ASSET_SPEC.
- Hạn chế: đây là cảnh dựng người sẵn, chưa có AI đi vào/chọn chỗ ăn; chưa thay art bếp trong ván chơi. Số nên chỉnh: sân4×3/cổng90px ở2×; rào tre cao24px, gỗ37px ở2×; bàn rộng≈94px/chiếu98px ở2×, độ chéo mái và khoảng trống giữa bàn. Dừng chờ duyệt mẫu, không commit/push.

---

## Khu bếp chữ nhật có hàng rào — Phác v3 (2026-10-04)

- Theo ảnh tham khảo mới và mô tả của người dùng: sân chữ nhật, mái che nấu góc trên-trái nghiêng về phía màn hình để thấy mặt trên/chiều sâu dọc; bàn ăn giữ thẳng, không xoay ngang. Dựng ba cấp hàng rào: tre / đá kê dưới tre / đá kê dưới gỗ, cổng giữa cạnh phía trước. Lấy bố cục/cách đọc hoạt động từ ảnh tham khảo, tự vẽ SVG theo nét/màu game.
- Mẫu tại build/art-review/2026-10-04/kitchen-compound-v3-rectangle: khung512×448 ở2×, sân512×384 tương ứng đề xuất4×3. Dùng lại mái/nồi/bàn v2, dời bàn sang phải; một người nấu/hai người ăn giống nhau ở cả ba cấp để chỉ so hàng rào. Tách hàng rào phía xa/gần và mái/bàn/người để thử che khuất. Lối giữa khu nấu/ăn và cổng không bị rào kín.
- Chỉ script/mẫu trong build và tài liệu đổi;174 SVG game không đổi so baseline, không sửa core/AI/ArtSpecs/footprint bếp hiện hành2×2. GAME_DESIGN ghi đề xuất mới/chờ duyệt, đồng bộ CLAUDE/AGENTS giữ phụ lục, ASSET_SPEC ghi khung thử riêng. Ba cấp này mới khác hàng rào, chưa thiết kế nâng cấp đầy đủ mái/khu nấu/bàn/số ghế.
- Import sạch; strict preview và runtime600 frame sạch, override.cfg đã xoá. Tự mở levels.png/layout.png: trái→phải cấp1→3, mái/nồi rõ, bàn cạnh ngang, hàng rào đá dưới tre/gỗ và lối vào đọc được.11 lớp SVG hợp lệ; không chạy lại bộ80 test đã qua ở v1 vì chỉ sửa cảnh phác riêng, không thay gameplay.
- Trước: kitchen-compound-v2-front/inhabited.png; sau: kitchen-compound-v3-rectangle/levels.png và layout.png. Cách xem: mở hai ảnh hoặc godot --audio-driver Dummy --path . res://build/art-review/2026-10-04/kitchen-compound-v3-rectangle/preview.tscn. Người đặt sẵn, chưa có AI chọn ghế/đi vào sân.
- Số cần duyệt: sân4×3 (chưa chốt footprint), cổng90px ở file2×, hàng rào cao25/30px ở file2×, hai chỗ ngồi mẫu. Dừng chờ duyệt bố cục/vật liệu, chưa thay game hay vẽ thêm công trình; không commit/push.

---

## Bếp chính diện nhìn từ trên — Phác góc v2 (2026-10-04)

- Theo phản hồi mẫu v1 nghiêng ngang gây khó chịu: dựng lại mái/bàn/bếp chính diện, chỉ nghiêng dọc từ trên xuống. Cạnh trước nằm ngang, mặt trên mái rộng, mặt bàn thấy rõ, miệng nồi elip ngang và lỗ lửa ở giữa. Giữ hai khu nấu/ăn, sân3×3, một người nấu/hai người ăn và lều hiện có làm mốc.
- Mẫu/script nằm riêng trong build/art-review/2026-10-04/kitchen-compound-v2-front; giữ v1 để so sánh. Không đổi asset game, footprint hiện hành, camera, AI, ArtSpecs hoặc rig game;174 SVG khớp hash trước thử. Góc mới chỉ là đề xuất chờ duyệt cho bếp, chưa thay chuẩn chung. Cập nhật GAME_DESIGN, đồng bộ CLAUDE/AGENTS giữ phụ lục và ghi mẫu trong ASSET_SPEC.
- Tự mở inhabited.png và layout.png, chỉnh người nấu xuống14px ở khung2× để tóc/mặt không bị mái che. Import/runtime600 frame sạch, strict preview/runtime sạch, override.cfg đã xoá. Cảnh đồ hoạ lần đầu lỗi thiết bị âm thanh WASAPI rồi fallback; chạy lại với --audio-driver Dummy sạch. Không chạy lại bộ80 test đã qua ở v1 vì lần này chỉ sửa mẫu SVG/script trong build và tài liệu, không thay core.
- Trước: kitchen-compound-v1/inhabited.png; sau: kitchen-compound-v2-front/inhabited.png và layout.png. Cách xem: mở ảnh hoặc godot --audio-driver Dummy --path . res://build/art-review/2026-10-04/kitchen-compound-v2-front/preview.tscn. Đây là cảnh dựng riêng, nhân vật đặt sẵn, chưa có AI chọn ghế/đi vào sân.
- Số cần duyệt: độ sâu mái≈100px/bàn≈48px ở khung2×, sân3×3 và hai ghế mẫu. Dừng chờ duyệt góc, chưa sửa các công trình khác hay lều; không commit/push.

---

## Phác khu bếp có người nấu và ngồi ăn — Bố cục chờ duyệt (2026-10-04)

- Theo bước phác đã đề xuất và được đồng ý: dựng khu bếp3×3 cạnh lều2×2 hiện có. Khu nấu sau-trái dưới mái cỏ một phần, tre/mây, nồi đất/bếp đá, một người khuấy; bàn gỗ thấp/ghế khúc gỗ phía trước-phải với hai người ngồi ăn. Chừa lối giữa hai khu và cửa sân phía trước-phải; cùng góc 3/4 trên cao/chếch với lều.
- Mẫu nằm riêng trong build/art-review/2026-10-04/kitchen-compound-v1: năm lớp SVG384×448, draw.py dùng helper generator nhưng không chạy main. preview.tscn/gd dựng rig01 thật của game; seated_preview.gd thử ghép tư thế ngồi với animation ăn/cầm món chín, chỉ trong bản phác. Mái/bàn/người tách lớp để xem che khuất; chưa phải hệ xếp lớp theo vị trí động.
- Không sửa lõi, AI, dữ liệu công trình, ArtSpecs hoặc asset game: hash174 SVG giữ nguyên so với trước phác. Bếp trong game vẫn2×2/kitchen_1 khung256×320/neo(0.5,0.925). Đề xuất3×3 và2/4/6 chỗ ăn theo cấp chưa chốt hay triển khai. GAME_DESIGN ghi rõ phác chờ duyệt, đồng bộ CLAUDE/AGENTS giữ phụ lục; ASSET_SPEC mô tả riêng mẫu build.
- Kiểm tra: năm SVG XML hợp lệ; import sạch; test thường80/80 và strict80/80; runtime600 frame thường/strict sạch; cảnh preview strict sạch; override.cfg đã xoá. Warning spawn ô chặn là test cũ cố ý; log Loc thông báo dùng tiếng Việt thay bản en còn thiếu. Tự mở inhabited.png và layout.png: người nấu lộ cạnh nồi, hai người ngồi hai phía bàn, tỉ lệ cạnh lều rõ.
- Trước: build/art-review/2026-10-04/kitchen-foundation-v1/after/board.png (bếp1 hiện hành). Sau/phác: kitchen-compound-v1/inhabited.png và layout.png. Đây là cảnh bố cục dựng riêng, không phải ảnh ván game seed42 hay bằng chứng AI tự vào bếp.
- Cách xem: mở hai ảnh hoặc chạy godot --path . res://build/art-review/2026-10-04/kitchen-compound-v1/preview.tscn để dựng lại. Hạn chế: nhân vật đặt sẵn, chưa tìm đường vào sân/đặt chỗ ghế/lấy món ăn; chỉ mẫu một cấp, chưa triển khai hành vi hay vẽ các công trình khác.
- Số cần duyệt: sân3×3, hai chỗ ngồi mẫu (đề xuất2/4/6 theo cấp), độ che của mái, khoảng cách bàn/nồi và độ rộng lối đi. Giữ tỉ lệ dân theo Balance.VILLAGER_SCALE; ảnh phóng đồng đều1.1 từ khung2× để dễ soi. Dừng chờ duyệt bố cục, không commit/push.

---

## Mẫu bếp cấp1 và ba cỡ móng góc xiên — Thử hướng công trình (2026-10-04)

- Theo đề xuất đã được đồng ý: làm thử bếp cấp1 + móng trước, không vẽ hết công trình. Bếp mái cỏ một dốc thấp trên tre/đốt/dây mây, mặt trên rộng xiên theo lều trước-phải; mở phía gần để thấy bếp đá/nồi đất miệng elip và hơi nước. Không dựng nhà vách đứng; cọc vẫn đứng thẳng, mái và đá/nồi có chiều sâu.
- Móng2×2/3×2/3×3 dùng nền đất vuông bo góc phủ đúng footprint, cọc thấp có mặt cắt/hông, dây căng và cành tre/đá bố trí xiên bên trong. Không xoay lưới hay làm nền thành hình thoi gây hụt diện tích. Cọc xa không bị cắt khung.
- Chỉ tools/gen_building_art.py và4 SVG kitchen_1/foundation_2x2/3x2/3x3 đổi hình; các cấp bếp2–3/lều/kho/lò/sân/tài nguyên giữ nguyên. Bếp256×320/neo0.5,0.925; móng256×256/384×256/384×384/neo0.5,1.0 giữ nguyên, ArtSpecs không đổi. Không sửa lõi/map/cost/AI/slots.
- Giữ vùng warning x128,y≈112 trên mái; chừa hai bên/mép trước cho các slot món chín hiện có. Generator tái sinh ổn định/hash chỉ4SVG đổi. XML/khung hợp lệ. Đồng bộ GAME_DESIGN/CLAUDE/AGENTS và ASSET_SPEC.
- Kiểm tra Godot: import sạch, lần chạy lại toàn bộ thường80/80, strict80/80, runtime600 frame sạch; override.cfg đã xoá. Lần thường đầu79/80 trượt test_controller_tap_assigns_and_moves ở bước đất trống; chạy riêng1/1 và full lần2 qua, không thay code. Test chọn vị trí đất ngẫu nhiên quanh làng, chưa xác định nguyên nhân trượt không ổn định. Warning spawn ô chặn là test cũ cố ý. Tự mở board.png, village_zoom_1.png, buildings.png: mái cạnh lều, warning trên mái, món chín không che. Ảnh construction.png ở wait40/speed4 đã xây xong; chụp thêm construction-early/wait5/speed1 để soi móng có thợ xây.
- Ảnh trước/sau: build/art-review/2026-10-04/kitchen-foundation-v1/before và after (seed42/buildings/jobs/wait40/speed4). Ảnh trước lấy từ lần chụp resources-v7 cùng tham số; hình công trình chưa đổi lúc đó. Bảng art: lều1/bếp1/móng2×2 hàng trên, móng3×2/3×3 hàng dưới; script soát/ảnh trong build.
- Cách thử: ván mới seed42, đặt bếp/cử thợ xây, sau xây cử người nấu; thấy mái xiên, nồi/hơi nước, món chín bày quanh chân. Đặt kho/lò để xem ba cỡ móng đúng vùng đặt. Hạn chế: bếp2–3/các công trình còn art cũ, chưa thành bộ3cấp đồng bộ; giàn giáo code cũ chưa vẽ lại. Chỉ mẫu chờ duyệt góc.
- Số có thể chỉnh: độ dốc mái/độ lộ nồi, độ cao cọc, màu cỏ/mái, vị trí khung dây trong móng. Không đổi khung/neo/sản lượng. Dừng chờ duyệt mẫu trước khi làm phần còn lại, không commit/push.

---

## Trở lại bụi dâu mềm, quả nhỏ và nhiều hơn — Bản thử v7 (2026-10-04)

- Người dùng đồng ý các tài nguyên khác v6 nhưng từ chối bụi dâu phân tầng, yêu cầu dùng lại bụi cũ. Khôi phục chính xác tán/lá/thân/bóng bụi v5 (đối chiếu14 phần tử đầu với board.svg v5); giữ các tài nguyên khác góc v6.
- Giữ dáng quả đỏ tròn mọng riêng lẻ đã duyệt, scale65% (nhỏ hơn35%); tăng số quả18/9/4 cho đầy/nửa/ít thay9/4/2. Bố trí rải đều, giữ khoảng lá giữa quả, không ghép đôi. Trụi vẫn cùng tán. Chỉ thay4 SVG bush và hàm bush() trong generator; khung192×160/neo0.5/0.91, hiển thị×0.5 không đổi.
- Sinh mới đầy100%, amount/capacity/sản lượng/save sau hái không đổi; không sửa core/map. GAME_DESIGN ghi ngoại lệ bụi theo yêu cầu mới nhất rồi đồng bộ CLAUDE/AGENTS; cập nhật ASSET_SPEC. Không tự ép lại góc v6 cho bụi đã bị từ chối.
- Kiểm tra: hash chỉ4 SVG bụi đổi so với v6, generator tái sinh ổn định; tán/lá/thân/bóng khớp v5. Godot import sạch; thường80/80, strict80/80; runtime600 frame sạch, override.cfg đã xoá. Warning spawn ô chặn là test cũ cố ý. Tự mở strawberries.png và village_zoom_1.png để xem quả nhỏ/nhiều trong game.
- Ảnh trước: build/art-review/2026-10-04/resources-v6/after; tham chiếu bụi cũ resources-v5/after/strawberries.png. Sau: build/art-review/2026-10-04/resources-v7/after, cùng seed42/buildings/jobs/wait40/speed4. Script soát/ảnh đều trong build.
- Cách thử: ván mới seed42, nhìn bụi dưới sân làng; click thấy30/30 rồi giao hái để giảm số quả và trụi. Hạn chế: hạt/điểm bóng nhỏ hơn khi thu xa, UI vẫn Bụi quả; bụi dùng dáng cũ theo yêu cầu trong khi loại khác giữ góc v6.
- Số nên chỉnh: scale quả0.65, số quả18/9/4 (chỉ hình, không capacity), khoảng cách giữa quả. Dừng chờ duyệt, chưa vẽ thêm, không commit/push.

---

## Đồng bộ góc xiên 3/4 của nhóm tài nguyên với lều — Bản thử v6 (2026-10-04)

- Phản hồi: kiểu dáng đã ổn nhưng tài nguyên vẫn cảm giác nhìn thẳng, không cùng góc lều trước-phải. Đổi cách dựng khối trong SVG, không xoay camera/lưới/sprite hay sửa core. Giữ vật liệu và kiểu dáng: cây lá rộng chia mảng, tre đốt/lá thuôn, dâu đỏ tròn mọng riêng lẻ, đá xám ngà, củi cành cong/chạc và sỏi.
- Cây/bụi: mặt trên tán xiên rộng, mặt hông thấp và tối, lớp xa vẽ trước/lớp gần đè lên. Thân đứng thẳng, gốc rễ chéo và hông thân phân sắc. Tre/gốc tre: gốc bố trí trước-sau trên đất, thân xa/gần khác chiều cao, đốt/miệng cắt nhìn từ trên. Gốc cây: mặt cắt xiên lớn/vân vòng, hông phải và rễ có chiều sâu.
- Đá: mặt trên rộng xiên, hông phải tối và mặt trước thấp riêng. Củi: cành trên hai trục đất xiên, có chồng lớp và đầu gỗ quay trước-phải. Sỏi: viên có mặt trên/hông thấp, phân bố trên cùng mặt đất; lượng ít làm nền thu nhỏ. Dâu vẫn 9/4/2 quả, cùng dáng/màu/điểm bóng; chỉ bố trí quả/lá trên khối tán mới, tránh ghép đôi/chồng quả.
- Generator có ground() cho hai trục (0.86,0.40)/(-0.65,0.50), phương đứng giữ thẳng; chỉ tính tọa độ SVG, không dùng mô hình 3D hay thay engine. Mảng lá dùng tọa độ cuối cùng để viền không co/giãn. Chỉ 20 SVG trong nhóm thử đổi; khung/neo/sinh đầy100%/save/sản lượng giữ nguyên, không đổi ArtSpecs. Cây thông tree_02/vách/nước/decor và công trình khác vẫn art cũ, ngoài nhóm vẽ thử này.
- Đồng bộ quy tắc góc trong GAME_DESIGN rồi copy CLAUDE/AGENTS, cập nhật ASSET_SPEC; bản v1–v5 là lịch sử kiểu dáng, không dùng làm chuẩn góc tài nguyên. Dừng chờ duyệt góc v6.
- Kiểm tra: generator tái sinh cùng hash, 20 khung SVG giữ nguyên. Import sạch; test thường80/80, strict80/80; runtime600 frame sạch, override.cfg đã xoá. Warning spawn ô chặn là test cũ cố ý. Tự mở board.png, village_zoom_1.png, resources.png, cliff.png; kiểm tra tán/bụi/đá/củi cạnh lều mẫu trong game.
- Ảnh trước: build/art-review/2026-10-04/resources-v5/after; sau: build/art-review/2026-10-04/resources-v6/after, cùng seed42/buildings/jobs/wait40/speed4. Bảng art có lều mẫu để đối chiếu hướng. Script soát/ảnh ở build.
- Cách thử: ván mới seed42, nhìn cụm cây/tre bên trái, dâu dưới sân làng, bãi đá/sỏi trước vách; giao hái/chặt/nhặt để xem các mức và gốc không đổi chân. Hạn chế: các hình ngoài nhóm thử còn góc cũ, map chưa đồng bộ toàn bộ; quả/hạt nhỏ khi thu xa.
- Số nên chỉnh: độ co chiều sâu/độ dốc của mặt tán, hông tán13–16px ở file2×, hai trục đặt vật và độ tối hông đá; giữ khung/neo và 9/4/2 quả. Không commit/push.

---

## Dâu đỏ hơn, giữ dáng đã duyệt — Bản thử v5 (2026-10-04)

- Người dùng duyệt hình dáng dâu v4, yêu cầu tăng đỏ. Chỉ thay ba màu trong generator: thân #DB6050→#DF3235, phần tối #CC5044→#C4262E, mảng sáng #EE7C63→#F1534A. Giữ điểm bóng/hạt vàng/đài xanh, tất cả path/vị trí/kích thước.
- Kiểm tra byte SVG với bản trước sau khi thay đúng ba màu: chỉ bush_100/50/20 thay đổi; bush_empty/cây/tre/hình khác giữ nguyên. Giữ 9/4/2 quả, khung192×160/neo0.5/0.91, sinh mới đầy100%, lượng/sản lượng/save không đổi. Không sửa lõi/map. Cập nhật GAME_DESIGN/CLAUDE/AGENTS/ASSET_SPEC.
- Import sạch; test thường80/80, strict80/80; runtime600 frame sạch; override.cfg đã xoá. Warning spawn ô chặn là test cũ cố ý. Tự mở strawberries.png và village_zoom_1.png, màu đỏ rõ hơn khi hiển thị trong game.
- Ảnh trước: build/art-review/2026-10-04/resources-v4/after/strawberries.png và village_zoom_1.png. Sau: build/art-review/2026-10-04/resources-v5/after, cùng seed42/buildings/jobs/wait40/speed4. Script soát/ảnh đều trong build.
- Cách thử: ván mới seed42, xem bụi dưới sân làng hoặc giao hái để thấy ba mức quả. Hạn chế: hạt/điểm bóng nhỏ khi thu xa; UI vẫn Bụi quả. Số nên chỉnh: ba mã màu dâu nêu trên; dáng đã duyệt giữ nguyên.
- Dừng chờ duyệt màu, không vẽ thêm, không commit/push.

---

## Dâu tây riêng lẻ, tròn mọng — Bản thử v4 (2026-10-04)

- Theo phản hồi: bỏ cặp 2 quả dính nhau, bố trí 9 quả đơn với khoảng lá giữa quả; mức nửa còn 4 quả, ít còn 2 quả, trụi giữ tán. Quả tròn đầy, đáy chỉ nhọn nhẹ, đỏ ấm, mảng sáng/điểm bóng gợi mọng nước; giữ hạt vàng nhỏ và đài xanh.
- Giữ cây đã duyệt, tre và hình khác; chỉ bush_100/50/20/empty thay đổi. Khung 192×160/neo 0.5/0.91, hiển thị ×0.5, luật sinh mới đầy 100% và lượng/sản lượng/save sau hái không đổi. Không sửa lõi/map. Cập nhật GAME_DESIGN/CLAUDE/AGENTS/ASSET_SPEC.
- Generator chạy lại cùng hash, kiểm tra SVG cùng khung. Godot import sạch; thường 80/80, strict 80/80; runtime 600 frame sạch. override.cfg đã xoá; warning spawn ô chặn là test cũ cố ý.
- Ảnh trước: build/art-review/2026-10-04/resources-v3/after/strawberries.png và village_zoom_1.png. Sau: build/art-review/2026-10-04/resources-v4/after, cùng seed42/buildings/jobs/wait40/speed4. Đã tự mở strawberries.png và village_zoom_1.png; hình quả riêng lẻ vẫn đọc được trong game. Script soát và ảnh ở build.
- Cách thử: ván mới seed42, xem bụi dưới sân làng, click thấy đầy30/30; giao hái để thấy quả giảm/trụi. Hạn chế: hình bụi cách điệu, UI vẫn tên Bụi quả; chi tiết hạt/điểm bóng nhỏ khi thu xa.
- Số nên chỉnh: 9/4/2 quả đơn (chỉ mật độ hình), độ tròn/cỡ quả, độ sáng điểm bóng; không thay capacity. Dừng chờ duyệt, không vẽ thêm, không commit/push.

---

## Đổi dâu tằm thành dâu tây — Bản thử v3 (2026-10-04)

- Người dùng duyệt cây v2; giữ nguyên cây, tre và mọi tài nguyên/công trình khác. Chỉ đổi bush_100/50/20/empty và phần bush() trong generator.
- Dâu tây cách điệu: quả đỏ thuôn tim, hạt vàng nhỏ, đài xanh, lá ba chét có mép răng cưa nhẹ. Giữ 9/4/2 chùm, mỗi chùm 2 quả; trụi giữ tán. Giữ khung 192×160, neo 0.5/0.91, hiển thị ×0.5.
- Luật sinh mới luôn đầy 100%, lượng sau hái/save và sản lượng không đổi; không sửa lõi/map. Đồng bộ GAME_DESIGN/CLAUDE/AGENTS, cập nhật ASSET_SPEC. Generator chạy lại cho cùng hash; chỉ bốn SVG bụi đổi so với v2.
- Kiểm tra: import sạch, test thường 80/80, strict 80/80, runtime 600 frame sạch; xoá override.cfg. Warning spawn ô chặn là test cũ cố ý. Tự mở board/strawberries và ảnh village_zoom_1/close_zoom_2 trong game.
- Ảnh trước: build/art-review/2026-10-04/resources-v2/after; sau: build/art-review/2026-10-04/resources-v3/after (seed42/buildings/jobs/wait40/speed4). Script soát và ảnh đều trong build.
- Cách thử: ván mới seed42, nhìn bụi ở dưới sân làng, click thấy đầy30/30; giao hái sẽ giảm quả rồi trụi. Tên UI vẫn Bụi quả; hình là bụi dâu tây cách điệu.
- Số nên chỉnh nếu cần: cỡ quả, độ đỏ/hạt vàng, 9/4/2 chùm; khung/neo không đổi. Dừng chờ duyệt hình, chưa vẽ thêm, không commit/push.

---

## Sửa cây lá rộng và đổi bụi quả thành dâu tằm — Bản thử v2 (2026-10-04)

- Theo phản hồi cây trông kỳ: tree_01 đổi từ tán tròn đều sang tán lệch chia mảng hữu cơ, khe lộ chạc và thân cong/gốc bè. Mặt trên sáng, mặt dưới tối, giữ khung 192×256 và neo 0.5/0.92.
- Bụi quả đổi sang dâu tằm cách điệu: lá tim có răng cưa nhẹ/gân, quả dài đỏ tím có nhiều hạt nhỏ, mỗi chùm 2 quả; 9/4/2 chùm cho 100/50/20, trụi giữ tán. Giữ khung 192×160/neo 0.5/0.91. Sinh mới luôn đầy 100%, lượng sau hái/save giữ như đợt trước.
- Chỉ 5 SVG tree_01/bush_100/50/20/empty đổi; generator tái sinh ổn định, tre/đá/củi/sỏi/lều/dân giữ hình. Không đổi code lõi/map/sản lượng. Đồng bộ GAME_DESIGN/CLAUDE/AGENTS và ASSET_SPEC.
- Kiểm tra: import sạch, thường 80/80, strict 80/80, runtime 600 frame sạch; override.cfg đã xoá. Warning spawn vào ô chặn là test cũ cố ý. Lần chụp đầu khởi chạy khi strict còn bật bị warning integer division của screenshot.gd cũ; đã dừng và chạy lại sau khi xoá override, không mở rộng sửa công cụ ngoài phạm vi.
- Ảnh trước: resources-v1/after; sau: build/art-review/2026-10-04/resources-v2/after. Chụp cùng seed 42/buildings/jobs/wait 40/speed 4; tự mở board.png và village_zoom_1/resources/work để kiểm tra kích thước trong game.
- Cách thử: ván mới seed 42, nhìn cây ở bìa làng, click bụi dâu thấy đầy 30/30; giao hái để thấy quả giảm rồi trụi, lá vẫn giữ dáng.
- Hạn chế: dâu là bụi cách điệu, tên UI vẫn Bụi quả; cây thông và phần map khác còn hình cũ. Chờ duyệt cây/dâu trước khi vẽ tiếp.
- Số có thể chỉnh: 9/4/2 chùm, 2 quả/chùm, sắc đỏ tím và độ tách mảng tán; khung/neo/sản lượng không đổi. Không commit/push.

---

## Thử tài nguyên/map cạnh làng — Cây lá rộng, tre, quả đỏ cam, đá và củi (2026-10-04)

**Trạng thái:** bản thử theo nhóm đã đề xuất, dừng chờ duyệt, chưa commit/push.

### Đã làm & quyết định
- Generator tài nguyên vẽ lại tree_01 và gốc cây, bụi quả 100/50/20/trụi, đá to/nhỏ 3 mức, củi 3 mức. Khối mềm/viền nâu/màu ấm, tán và mặt đá nhìn từ trên, quả rừng đỏ cam; giữ khung/neo cũ. Củi có cành cong/chạc và mặt cắt gỗ. Sỏi giữ hình cũ ở đợt thử.
- Thêm tree_03 (176×272, neo 0.5/0.93) và bamboo_stump (96×72, neo 0.5/0.8) vào ArtSpecs/ASSET_SPEC. Tre là biến thể TREE cho cùng gỗ/rìu/cây non/mọc lại, không thêm tài nguyên/AI. Giữ tree_02 thông cũ. Trong phần cây lá rộng, 28% dùng hình tre theo cùng RNG/phân bố rừng; không sửa địa hình, đường đi hay vị trí mỏ của seed.
- Map mới bụi quả và đá tảng đầy amount=capacity; sỏi/củi giữ ngẫu nhiên 50–100%. Giữ lượt RNG của lượng ban đầu để vị trí map không lệch; đá tảng do vách lở cũng đầy. Save restore giữ lượng đã khai thác, không ép đầy lại. Hai test mới kiểm tra nhiều seed, lượng sỏi/củi, tre, lượng quả trong save và gốc/mọc lại tre.
- Chỉ thay hình và phần code cần cho biến thể tre/luật lượng được yêu cầu, không sửa AI/luật việc/camera. Generator chạy lại giữ hình; hash cho thấy hình thay đổi chỉ trong nhóm thử, lều/dân/nhà/sỏi/cảnh khác giữ nguyên. GAME_DESIGN/CLAUDE/AGENTS/ASSET_SPEC đồng bộ mô tả.

### Kiểm tra
- Godot 4.7.2 import sạch; toàn bộ test thường **80/80**, strict **80/80**, runtime headless 600 frame sạch. Đã xoá `override.cfg`. Warning ô bị chặn của Commands.spawn_villager là test cố ý cũ; không có warning mới.
- Hai test mới qua: sinh lượng nhiều seed/biến thể tre; spawn trực tiếp, save giữ quả đã hái, gốc tre/mọc lại. Generator chạy lại cho cùng kết quả; tự mở bảng art và ảnh village/resources/cliff/work, giữ khung/neo và màu/viền hợp với lều.

### Cách xem & hạn chế
- `build/art-review/2026-10-04/resources-v1/before/` và `after/`: cùng seed 42, buildings/jobs/wait 40/speed 4. Tự mở village_zoom_1/resources/cliff/work để soi trong game; board.png là bảng hình và các mức khai thác cạnh lều mẫu, script soát chỉ ở build.
- Chạy ván mới seed 42, nhìn cây/tre ở bìa làng; click bụi quả trước hái sẽ đầy 30/30, đá 16/16; hái quả/chặt tre rồi lưu/nạp vẫn giữ lượng và gốc. Tre non theo scale cây non, tre chặt còn gốc rỗng, mọc lại đúng tre.
- Cây thông, vách đá, nước và decor còn art cũ; tre UI vẫn tên chung Cây, dùng cùng khúc gỗ khi khuân. Chưa thêm tre trang trí riêng hay bố trí riêng ven nước. Đây là đợt thử, chưa làm hết map.

### Số nên chỉnh
- BAMBOO_CHANCE=0.28 trong phần cây lá rộng; độ dày/độ xanh tán, độ dày thân/lá tre, quả 9/4/2 chùm; độ sáng mặt đá, cỡ củi. Khung/neo cũ không đổi, không chỉnh giá/nhu cầu/sản lượng.

---

## Chuẩn bị tài nguyên — Bụi quả mới sinh luôn đầy (2026-10-04)

**Trạng thái:** ghi yêu cầu bổ sung ở bước bàn ý tưởng; chưa bắt đầu đợt vẽ tài nguyên/map, chưa đổi core hay commit/push.

- Người dùng chốt bụi quả lúc sinh luôn 100%; chỉ sỏi/củi khác lượng ban đầu. Bụi quả vẫn có hình ít quả/trụi sau khi hái và đầy khi mọc lại. Đủ 100% là amount=capacity, không chỉ ép texture đầy.
- Cập nhật GAME_DESIGN mục 9.1, đồng bộ CLAUDE/AGENTS giữ phụ lục, thêm quy tắc vào ASSET_SPEC. Không sửa lịch sử DEVLOG cũ.
- Kiểm tra code hiện tại: MapGenerator còn random lượng khởi đầu cho bụi quả và đá tảng; ResourceNode mặc định spawn đầy và bụi mọc lại đã đầy. Khi triển khai đợt tài nguyên/map cần đổi lượng khởi đầu của các mỏ ngoài sỏi/củi theo quy tắc mới; không áp dụng lên lượng còn lại trong save đã chơi.
- Cách kiểm tra ở đợt triển khai: map mới nhiều seed, mọi bụi amount=capacity và hình đầy; sỏi/củi có lượng khác nhau; hái quả rồi load save vẫn giữ lượng đã hái. Đợt này chỉ ghi tài liệu, không có ảnh hay test game mới, không chỉnh con số.

---

## Chốt và đồng bộ phong cách nghệ thuật — Prehistoric Tribes gợi nét Việt (2026-10-04)

**Trạng thái:** chỉ tài liệu theo yêu cầu; không vẽ thêm, không đổi code/core, không commit/push.

- Đã hiểu và ghi hướng chung: tiền sử thô mộc/thủ công/hơi ngố dễ thương; màu ấm, viền nâu, dáng mềm; góc 2D từ trên đồng thời chếch bên, chiều sâu ngang và cửa xiên, lều trước-phải, lưới/camera giữ nguyên.
- Nét Việt là gợi nhẹ bằng tre/mây/cỏ/rơm/đồ đất và hoa văn Lạc Việt, không ép phân cấp thành thời kỳ lịch sử hoặc mọi nhà thành mái thuyền/nhà sàn. Lều da thú/cỏ đã được duyệt; ba cấp khác bằng cỡ, độ hoàn thiện và trang trí, giữ cùng khung/neo/footprint. Vẻ rách của cấp 1 chỉ là art, không thêm luật hư hại.
- Sửa nguồn chính GAME_DESIGN mục 7, thay mô tả góc/vật liệu/phân cấp cũ mâu thuẫn; copy thiết kế sang CLAUDE/AGENTS, giữ nguyên dòng đầu Codex và phụ lục từng file. ASSET_SPEC thống nhất cùng hướng, dẫn bộ ảnh tents-v7 làm chuẩn; DEVLOG cũ giữ làm lịch sử.
- Cách xem: đọc GAME_DESIGN mục 7/đầu ASSET_SPEC và mở `build/art-review/2026-10-04/tents-v7/after/footprint.png`, `levels.png`, `village_zoom_1.png`. Không cần chạy game cho thay đổi này; không sinh asset mới.
- Kiểm tra: đối chiếu phần thiết kế của hai bản hướng dẫn với nguồn chính, phụ lục không đổi; rà mô tả cũ và diff whitespace; hash SVG/generator/ArtSpecs/rig không đổi. Không chạy lại test game vì chỉ sửa Markdown.
- Còn biết: công trình khác chưa được vẽ lại/duyệt dáng cuối; vật liệu của chúng là gợi ý. Số art có thể tinh chỉnh ở đợt sau: thân lều 76%/89%/100%, lượng cỏ, độ rõ hoa văn; chưa chỉnh số lần này.

---

## Phân biệt ba cấp lều da/cỏ — Nhỏ cũ → lớn gọn → trang trí Lạc Việt (2026-10-04)

**Trạng thái:** xong hình thử theo hướng đã thống nhất, chờ duyệt phân cấp; không commit/push, dừng ở ba lều.

### Đã làm & quyết định
- Cả ba dùng da thú và phủ cỏ/rơm, giữ dáng thuôn nhọn/cửa chếch phải đã được người dùng đồng ý. Cỡ nhóm thân/phụ kiện quanh chân (128,276) là 76%/89%/100%; sân, khung 256×300, neo và footprint 2×2 cố định. Cấp 1 nhỏ nhưng diện tích xây gameplay vẫn bằng cấp 2/3.
- Cấp 1 da nâu cũ, mép sờn/răng rách, lỗ rách và miếng vá thô, bó cỏ thưa. Cấp 2 da sáng lành, bỏ rách/vá thô, dựng ngay ngắn, mái cỏ gọn. Cấp 3 lớn nhất, chóp cỏ rộng hơn và tua rơm buộc cửa, chim Lạc/mặt trời/dải răng cưa màu đất-đồng trên da; hoa văn cách điệu gợi Lạc Việt, không tái dựng sử chính xác.
- Ghi quyết định đã chốt vào GAME_DESIGN mục 7 và đồng bộ CLAUDE/AGENTS, giữ phần phụ lục. ASSET_SPEC cập nhật mô tả/tỉ lệ. Chỉ sửa generator/ba SVG lều và tài liệu; móng, thổ dân/rig, camera/map/core không đổi. Hash trước/sau chỉ ba SVG lều đổi.

### Kiểm tra
- Godot 4.7.2 import sạch; test thường **78/78**, strict **78/78**, runtime headless 600 frame sạch. Đã xoá `override.cfg`. Warning ô bị chặn của `Commands.spawn_villager` thuộc test cố ý cũ; không có cảnh báo mới.
- Đã tự mở footprint, levels và village_zoom_1 sau sửa; khác cỡ/dáng đọc rõ trong làng. SVG hợp lệ, khung giữ nguyên; generator chạy lại cho cùng kết quả, hash chỉ ba SVG lều đổi.

### Cách xem & hạn chế
- Trước: `build/art-review/2026-10-03/tents-v6/after/levels.png`, `village_zoom_1.png`, `footprint.png`. Sau: cùng tên trong `build/art-review/2026-10-04/tents-v7/after/`; bảng ba cấp trái→phải trên ô xanh 2×2. Chụp seed 42, buildings/jobs/wait 40/speed 4, tự mở bảng và ảnh trong game. Trong game xây/nâng Lều 1→2→3 rồi zoom gần/xa để thấy cỡ, da/cỏ và hoa văn.
- Các công trình khác vẫn hình cũ; lỗ rách/đường khâu và hoa văn nhỏ sẽ giảm độ rõ khi zoom xa. Cỡ lều 1 nhỏ trong cùng sân là chủ ý theo yêu cầu, không đổi diện tích đi lại/xây.

### Số nên chỉnh
- Thân 0.76/0.89/1.0 quanh (128,276); độ phủ cỏ: thưa/gọn/dày tới y≈136/146/162 trước scale; màu da cũ và số lỗ rách; độ lớn/chất màu chim Lạc/mặt trời/tua rơm. Chỉ là số hình, không cân bằng game.

---

## Thử lều da thú thuôn nhọn — Ít rơm ở chóp, nét Việt nhẹ (2026-10-04)

**Trạng thái:** bản thử theo yêu cầu mới nhất, chờ duyệt; không commit/push, chưa vẽ thêm hình khác.

### Đã làm & quyết định
- Người dùng đổi hướng: lều da thú giống cảm giác Prehistoric Tribes, dáng thuôn nhọn, phủ chút rơm và gợi nét Việt. Yêu cầu mới ưu tiên hơn vật liệu toàn lá/dáng vòm và điều cấm lều da trong spec cũ; chỉ thử ba lều, chưa sửa thiết kế chung của mọi công trình.
- Thân da nâu kem, chân rộng/elip, đỉnh lệch sau-trái; khe cửa và chân cửa xiên trước-phải. Đường khâu thô, nếp da, mép da cửa kéo mở/buộc mây; mái/thân liền, không vách/sàn/cột nhà. Chóp rơm nhỏ có sợi tơi và dây buộc; phần lớn bề mặt vẫn da.
- Cấp 1 da đơn giản; cấp 2 thêm da vá; cấp 3 thêm miếng tre đan và mặt trời nhỏ lấy cảm hứng trống đồng. Khung tre ngắn/dây mây/cọc neo giữ nét vật liệu Việt, không chép texture/hình gốc. Dáng tưởng tượng, không khẳng định chính xác lịch sử.
- Chỉ thay `tent()` trong generator, ba SVG sinh ra, ASSET_SPEC và DEVLOG. Tên file, khung 256×300, neo (128,276), diện tích/sân 2×2, móng, dân/rig, camera/map/core giữ nguyên. Hash soát trước/sau chỉ ba SVG lều đổi.

### Kiểm tra
- Godot 4.7.2 import sạch, test thường **78/78**, strict **78/78**, runtime headless 600 frame sạch. Đã xoá `override.cfg`. Cảnh báo `Commands.spawn_villager` ô bị chặn là test cố ý cũ; không có cảnh báo mới.
- Đã tự mở footprint, levels và village_zoom_1; SVG hợp lệ, khung 256×300 giữ nguyên; generator chạy lại cho cùng kết quả, hash chỉ ba SVG lều đổi.

### Cách xem & hạn chế
- Trước: `build/art-review/2026-10-03/tents-v5/after/levels.png`, `village_zoom_1.png`, `footprint.png`. Sau: cùng tên trong `tents-v6/after/`; bảng ba cấp trái→phải. Chụp seed 42, buildings/jobs/wait 40/speed 4; script/ảnh soát nằm trong build. Trong game xây/nâng lều 1→2→3, zoom gần xem khâu/rơm, zoom xa xem dáng và cửa phải.
- Các nhà khác vẫn hình cũ. Các cấp dùng cùng dáng; chi tiết vá/tre đan có thể khó thấy khi zoom xa. Đây là bản duyệt vật liệu/dáng, chưa vẽ thêm công trình hay nhân vật.

### Số nên chỉnh
- Đỉnh `(110,76/69/61)`, chân elip `(128,247)` bán kính `(112,43)`; bó rơm tới y≈146. Cửa đỉnh `(181,207)`, chân xiên `(158,279)`→`(218,261)`. Có thể chỉnh độ thuôn, lượng rơm, sắc da và vị trí vá/tre đan; chỉ là số art.

---

## Thử lều lá vòm thấp — Cửa quay trước-phải, bỏ dáng nhà (2026-10-03)

**Trạng thái:** bản thử theo hai góp ý mới, chờ duyệt; không commit/push, chưa làm thêm hình khác.

### Đã làm & quyết định
- Người dùng thấy góc chếch gần đúng, nhưng muốn lều tiền sử thay vì nhà và cửa hướng bên phải. Giữ góc cao chếch bên, đảo hướng vẽ trong SVG; camera/lưới không đổi.
- Đổi ba cấp sang lều khung tre uốn lợp lá cọ vòm thấp, mái chạm gần đất, mặt đầu cũng phủ lá và khe cửa có mép cuộn buộc dây mây. Bỏ vách đứng, sàn nhà, cột nhà sàn/cầu thang và mái thuyền cứng của bản trước. Không dùng lều da/teepee. Đây là lựa chọn đơn giản để thử dáng lều; thay hướng nhà sàn cũ cho đợt này theo yêu cầu mới.
- Cấp 1 ít gia cố; cấp 2 thêm đai mây và đá neo; cấp 3 mái vàng ấm, đai mây, mặt trời nhỏ. Cao vòm tăng nhẹ thay xây thêm tầng/vách. Viền nâu #4E342E, sân đất vẫn trải 2×2.
- Chỉ đổi `tent()`/ba SVG sinh ra, ASSET_SPEC và nhật ký. Giữ khung 256×300, neo (128,276), tên file, móng/thổ dân và core; hash generator xác nhận chỉ ba SVG lều đổi.

### Kiểm tra
- Godot 4.7.2 import và runtime headless 600 frame sạch; strict **78/78**, đã xoá `override.cfg`. Cảnh báo ô bị chặn trong `Commands.spawn_villager` thuộc test cố ý cũ, không có cảnh báo mới.
- Lượt thường đầu **77/78**: `test_village_lives_for_five_minutes` bắt một người tán gẫu cách điểm neo 3 ô. Cùng bộ SVG đó lượt strict và lượt thường chạy lại đều **78/78**; lỗi không tái hiện, ghi nhận tình huống mô phỏng không ổn định, không chỉnh core ngoài phạm vi art.
- Tự mở bảng ba cấp, levels và village; XML/SVG hợp lệ, khung 256×300, hash chỉ ba SVG lều đổi. Script/ảnh soát nằm trong build.

### Cách xem & hạn chế
- Trước: `build/art-review/2026-10-03/tents-v4/after/levels.png`, `village_zoom_1.png`, `footprint.png`. Sau: cùng tên trong `tents-v5/after/`; bảng riêng ba cấp trái→phải trên ô xanh 2×2. Tự mở ảnh để xem cửa quay phải và mái sát đất. Trong game xây/nâng lều 1→2→3 rồi zoom gần.
- Các nhà khác vẫn dáng/góc cũ; cấp 1/2 gần nhau khi zoom xa, chủ yếu phân biệt qua đai mây. Hình lấy cảm hứng vật liệu tiền sử, không nhằm tái dựng lịch sử hay chép hình gốc.
- Chụp seed 42, buildings/jobs/wait 40/speed 4; dùng bản sao screenshot trong build chỉ lưu levels/village do ổ C ít chỗ. QA script/ảnh ở build; tool game không đổi.

### Số nên chỉnh
- Chiếu ngang `−0.60/−0.55`, dốc hai trục `0.28/−0.45`, co cao `0.85`; vòm `112/121/129`, cửa `65/70/74`, độ rộng thân 200, chiều sâu 192 đơn vị vẽ. Chỉ là số art, không cân bằng game.

---

## Thử lều chếch bên — Góc cao có mặt cửa xiên và vách bên (2026-10-03)

**Trạng thái:** bản thử theo xác nhận mới nhất, chờ duyệt; không commit/push, không vẽ thêm.

### Đã làm & quyết định
- Người dùng làm rõ và xác nhận: muốn nhìn từ trên đồng thời chếch bên như lều Prehistoric Tribes. Hướng mới thay yêu cầu trực diện/không thấy hai vách trong tài liệu cũ cho đợt thử này; chưa đổi thiết kế chung cho mọi hình khi chưa duyệt.
- Vẽ lại ba cấp qua `tent()` trong generator: cửa/đầu hồi trước-trái xiên, vách bên sau-phải, sống mái chạy chéo. Cấp 1 tre/lá chữ A; cấp 2 vách tre đan, kê đá; cấp 3 nhà sàn, hai đầu mái thuyền nhấc cong, cầu thang xiên, mặt trời theo mặt mái. Nền sân đất phủ 2×2, nhà nằm chéo trong sân.
- Giữ tên, khung 256×300, neo (128,276); móng, thổ dân, camera, lưới, dữ liệu/core không sửa. Hash xác nhận chỉ ba SVG lều đổi khi chạy generator. Cập nhật ASSET_SPEC theo bản thử.

### Kiểm tra
- Godot 4.7.2 import sạch; test thường **78/78**, strict **78/78**; runtime headless 600 frame sạch. Đã xoá `override.cfg`. Cảnh báo ô bị chặn của `Commands.spawn_villager` thuộc test cố ý cũ, không có cảnh báo mới.
- Tự mở `footprint.png`, `levels.png`, `village_zoom_1.png`; SVG/PNG hợp lệ, khung/neo không đổi. Chỉ ba SVG lều thay đổi theo hash trước/sau.

### Cách xem & hạn chế
- Ảnh trước: `build/art-review/2026-10-03/tents-v3/after/levels.png`, `village_zoom_1.png`. Ảnh sau: `build/art-review/2026-10-03/tents-v4/after/levels.png`, `village_zoom_1.png`, `footprint.png` (ba cấp trái→phải). Tự mở ảnh soát mái/cửa, footprint và khi đứng cạnh công trình cũ; chụp cùng seed 42, buildings/jobs/wait 40/speed 4.
- Trong game xây/nâng lều cấp 1→3, zoom gần để xem cửa/vách/thang xiên. Công trình khác vẫn chính diện; cấp 1/2 cùng dáng mái nên zoom xa hơi giống nhau. Đây là thử hướng, chưa khẳng định đạt phong cách cuối cùng.
- Ổ C hết chỗ: dọn ảnh phụ do Codex sinh ở các đợt lều, giữ levels/village/footprint đã gửi. Bản chụp lại dùng bản sao tool trong build chỉ lưu levels/village để hạn chế dung lượng; tool game giữ nguyên.

### Số nên chỉnh
- Hệ số xiên ngang/sâu `0.60/0.55`, độ dốc trên ảnh `0.28/−0.45`, co chiều cao `0.85`; cao nóc `110/120/146`, độ cong mái thuyền `18`. Tất cả là số vẽ trong SVG, không phải cân bằng game.

---

## Sửa khối mái lều — Bớt nhìn từ trên thẳng xuống, cửa rõ hơn (2026-10-03)

**Trạng thái:** bản sửa hình, chờ người dùng duyệt; chưa commit, chỉ sửa 3 cấp lều.

### Đã làm & quyết định
- Theo góp ý mới: bản mái phẳng chưa có cảm giác căn lều dựng trên đất như ảnh Prehistoric Tribes. Giữ hướng trực diện/nhìn nghiêng từ trên và vật liệu Việt Nam đã chốt, nhưng không ép mặt trước quá mỏng để lấp ô 2×2.
- Cấp 1/2: mép ngoài, mép trước và các hàng lá cong để mái phồng; chuyển sắc nhẹ trong SVG tạo phần sáng trên khối mái và phần tối ở rìa. Rút sống mái sâu từ 202 px xuống 159/157 px; tăng đầu hồi từ ~49/57 lên ~88/98 px; cửa cao 56 px file, dễ đọc hơn khi nhìn trong làng. Sàn/nền vẫn trải footprint; cấp 2 giữ vách tre đan và sàn đá.
- Cấp 3: mái thuyền phồng, hàng lá cong, sáng giữa/tối gần mép; nâng mép mái trước từ ~245 lên ~222..231 để lộ thêm vách/cửa. Giữ cột gỗ/thang tre và mặt trời nhỏ, dời hoa văn lên y=166.
- Chỉ sửa `tent()` trong generator và 3 SVG sinh ra, cùng mô tả ASSET_SPEC/nhật ký. Khung 256×300, neo (128,276), footprint, móng, thổ dân và core giữ nguyên (đối chiếu hash). Không đổi camera/renderer, không vẽ nhà/vật nào khác.

### Kiểm tra
- Godot 4.7.2 import sạch; test thường **78/78**, test strict **78/78**; runtime headless 600 frame sạch. Đã xoá `override.cfg`. Warning `Commands.spawn_villager` ô bị chặn thuộc tình huống cố ý của test cũ; không có cảnh báo mới.
- Kiểm tra SVG/XML, khung 256×300, PNG hợp lệ và generator chạy lại cho cùng kết quả. Tự mở ảnh ba cấp riêng, `levels.png` và `village_zoom_1.png` sau sửa để kiểm tra mái/cửa và tỉ lệ cạnh nhà cũ.

### Ảnh & cách xem
- `build/art-review/2026-10-03/tents-v3/before/` giữ `levels.png`, `village_zoom_1.png` của bản ngay trước; `after/` là bản sửa, chụp cùng seed 42 và `--buildings --jobs --wait=40 --speed=4`. Tự mở cả hai ảnh sau trong game; mở thêm `after/footprint.png` để soi ba cấp từ trái sang phải, mái/cửa và ô 2×2.
- `REVIEW.md` gom ảnh trước/sau; script/ảnh soát chỉ nằm trong build có `.gdignore`. Generator chạy lại không đổi thêm SVG nào.
- Chạy game, xây/nâng Lều cấp 1→2→3; zoom gần xem mái cong/cửa, zoom xa xem dáng có đọc thành căn lều. Các công trình khác còn hình cũ theo phạm vi yêu cầu; cấp 1/2 vẫn cùng dáng mái chữ A.

### Số nên tinh chỉnh
- `roof_front` 190/180, `eave_front = roof_front + 80`, độ cong mép mái và chuyển sắc `palm_light`/`palm_dark`; cửa từ y=226 tới 282. Cấp 3: mép mái 222..231, vách/cửa hiện tới 266; độ phồng màu ở `boat_roof`. Đây là số hình ảnh, không đổi cân bằng game. Góc vẽ cách điệu cần người dùng duyệt, không khẳng định giống hệt hình gốc.

---

## Sửa lều góc cao — Tre/lá cọ → nhà sàn mái thuyền (2026-10-03)

**Trạng thái:** xong bản sửa theo ảnh mẫu, chờ duyệt — chưa commit; dừng, chưa vẽ thêm hình khác.

### Đã làm & quyết định
- Đọc lại GAME_DESIGN/AGENTS mục 7 mới và mục nhật ký mới nhất. Bản trước vẫn thiếu chiều sâu footprint: mái cong chỉ nới dáng, chưa cho cảm giác đứng trên cao nhìn xuống. Bản này dùng mặt mái trải từ sát mép sau tới sát mép trước ô 2×2; đầu hồi/cột/thang co thấp, giữ hướng trực diện và lưới vuông.
- Chỉ vẽ lại `tent_1/2/3` qua `tools/gen_building_art.py`: cấp 1 lán tre chữ A lợp lá cọ, hai mái hình thang trái sáng/phải tối, nóc dài trước–sau và cửa nhỏ; cấp 2 nhà lá có nẹp mái/dây mây, sàn thấp kê đá vôi, vách tre đan; cấp 3 nhà sàn nhỏ mái cong hình thuyền, dải mái sau tối, mái trước rộng sáng, cột gỗ, thang tre ngắn, mặt trời 12 tia màu đồng nhỏ.
- Vật liệu và màu theo nét Việt Nam tiền sử đã chốt: tre/nứa vàng nâu, lá khô vàng xanh, mây, gỗ, đá vôi. Bỏ lều da, miếng vá da, lông chim. Hoa văn lấy cảm hứng trống đồng, cách điệu cho dễ đọc; không nhằm tái dựng lịch sử chính xác.
- Giữ khung 256×300, neo (0.5, 0.92) = (128, 276), footprint 2×2, tên file. Cập nhật mô tả ASSET_SPEC; không cần đổi ArtSpecs. Hash đối chiếu trước/sau: chỉ 3 SVG lều thay đổi, móng, các mảnh thổ dân, rig, dữ liệu công trình và mọi SVG khác giữ nguyên.

### Kiểm tra
- Godot 4.7.2 import sạch; test thường **78/78**, test strict **78/78**; runtime headless 600 frame sạch. Đã xoá `override.cfg`. Warning `Commands.spawn_villager` ô bị chặn thuộc tình huống cố ý trong test cũ; không có cảnh báo mới.
- Chụp trước/sau cùng seed 42, `--buildings --jobs --wait=40 --speed=4`. Tự mở `levels.png`, `village_zoom_1.png` và ảnh riêng trên ô xanh 2×2, so với phác thảo người dùng. Nền/roof kéo sâu cả hai hàng ô; phần đứng phía trước thấp, không có mặt tường bên isometric. Màu/viền giữ hợp với công trình cũ.
- PNG lần đầu có file rỗng do ổ C hết dung lượng. Đã dọn ảnh phụ có thể tạo lại và cache import của ảnh QA do Codex sinh trong build; giữ ảnh đã liên kết/ảnh duyệt. Chụp lại thành công và kiểm tra PNG hợp lệ. `build/.gdignore` giữ nguyên.
- Toàn bộ ảnh, script soát footprint và log nằm trong `build/art-review/2026-10-03/tents-v2/` (không thuộc mã game). `before/levels.png`, `after/levels.png`, hai `village_zoom_1.png` là ảnh so sánh; `after/footprint.png` có ô xanh/đường chia ô chỉ để duyệt. `REVIEW.md` gom các đường dẫn.

### Cách xem thử
- Mở `before/levels.png` → `after/levels.png`: cấp 1 ở trái trên, cấp 2 phải trên, cấp 3 trái dưới; xem mái trải sâu và đầu hồi thấp. Mở `after/footprint.png`: ba cấp từ trái sang phải, mỗi hình nằm trên ô xanh 2×2.
- Chạy game, đặt Lều ngủ, giao thợ xây và nâng cấp lên 2/3; zoom gần để xem nẹp/vách tre/sàn đá và thang/hoa văn. Ngủ trong lều vẫn dùng cửa và hành vi cũ.

### Còn biết & số nên tinh chỉnh
- Các công trình khác còn hướng vẽ/phong cách cũ theo phạm vi được yêu cầu. Cấp 1/2 cùng dáng mái chữ A; khi zoom xa, sàn đá/nẹp/vách đan của cấp 2 hơi khó phân biệt.
- Số hình ảnh trong `tent()`: footprint x=0..256, y=44..300; nền x=5..251, y=47..296; sống mái cấp 1/2 từ y=31/23 tới 233/225 (chiều sâu 202 px), độ co đầu hồi ~49/57 px. Cấp 3 mái từ y≈27 tới 245, vách/sàn/cột/thang gọn trong 245..300; hoa văn mặt trời bán kính 11 px, 12 tia. Không chỉnh con số cân bằng game.

---

## Sau bản thử góc cao — Góp ý + chốt nét Việt Nam thời tiền sử (2026-10-03)

**Trạng thái:** chỉ tài liệu — chưa commit.

- Duyệt bản thử của Codex: móng 2×2 và bộ thổ dân 01 đạt; **lều vẫn nhìn ngang tầm mắt** — không xoay là đúng, nhưng camera chưa nâng lên cao (chân là đường thẳng ở mép trước, chỉ phủ nửa trước 2×2, không thấy đỉnh). Ghi quy tắc góc cao vào GAME_DESIGN mục 7: chân phủ kín diện tích, chiều cao vẽ rất ngắn, phần lớn hình là mặt trên / mái.
- **Chốt phong cách công trình: Việt Nam thời tiền sử** (GAME_DESIGN mục 7, ASSET_SPEC): tre / lá cọ / mây / đá vôi / đất nung, hoa văn trống đồng; cấp 1 lán tre lá (Hoà Bình – Bắc Sơn) → cấp 3 nhà sàn mái cong hình thuyền (Đông Sơn); gợi ý riêng cho hang, lửa trại, lều, bếp, kho, lò rèn (xưởng mài rìu đá → lò đất), sân nhảy (cây nêu → trống đồng), móng. Bỏ lều chóp kiểu teepee (của thổ dân Bắc Mỹ).
- Thêm `build/.gdignore` để Godot không import ảnh / script soát lại của Codex trong `build/`.

---

## Thử hướng vẽ góc cao — Lều 3 cấp + bộ thổ dân 01 (2026-10-03)

**Trạng thái:** xong bản thử, chờ duyệt hướng vẽ — chưa commit; dừng ở phạm vi này.

### Đã làm
- Vẽ lại `tent_1/2/3` trong `tools/gen_building_art.py`: mái da bo tròn chiếm phần lớn hình, kéo sâu về phía sau theo trục dọc, mặt trước thấp (~64 px file), cửa nhỏ ở giữa chân. Giữ khung 256×300, neo (128, 276), diện tích 2×2 và bảng màu/viền cũ. Cấp 2 thêm miếng vá và vòng đá; cấp 3 thêm hoa văn và lông chim nằm trọn khung.
- Vẽ lại móng 2×2: nền vuông bo góc phủ 128×128 px hiển thị, cọc thấp có mặt trên elip, dây căng; cọc phía sau không bị cắt bởi mép ảnh. Móng các cỡ khác giữ nguyên.
- SVG viết tay bộ `head_01`, đủ 5 `face_01_*`, `hair_01`, `body_01`, `arm`, `leg`: đỉnh tóc lớn hơn, mặt thấp vẫn đọc được, vai có mặt trên và thân/chân ngắn. Giữ khung đầu 80×80; đổi khung thân 56×40, tay 16×28, chân 22×26. Điểm neo tỉ lệ giữ nguyên, cập nhật ASSET_SPEC và ghi chú ArtSpecs.
- Chỉ chỉnh hằng vị trí của VillagerRig (vai/hông/cổ, khoảng cách bàn tay, đồ khuân, biển giơ, đồ sau lưng); không sửa hoạt họa hay lõi game. Các file head_02–03, hair_02–05, body_02–03 và công trình khác không đổi. Sinh lại bằng `python tools/gen_building_art.py` không tạo khác biệt ở những hình ngoài phạm vi.

### Kiểm tra & ảnh duyệt
- Import Godot 4.7.2 sạch; test thường 78/78 và test với `tools/strict_warnings.cfg` 78/78; headless 600 frame sạch. Đã xoá `override.cfg`. Warning `Commands.spawn_villager` trên ô bị chặn là tình huống cố ý của `test_boot_loads_mode`; không có cảnh báo GDScript mới.
- Lượt test đầu có 1 lần trượt `test_controller_tap_assigns_and_moves`: hàm chọn ô trống lấy ngẫu nhiên ô không bị chặn, nhưng điểm click vẫn có thể trúng hình vật thể. Hai lượt đầy đủ tiếp theo đều qua, không sửa controller/map/test ngoài phạm vi hình.
- Chụp trước/sau bằng seed 42, `--buildings --jobs --wait=40 --speed=4`, tự mở xem `levels.png`, `construction.png`, `village_zoom_1.png`, `work.png`. Màu/viền/kích thước lều mới đứng hợp cạnh nhà cũ; cảnh báo bếp/lò vẫn trên mái (khung và neo công trình không đổi).
- 40 giây đủ xây xong móng bếp, nên chụp thêm `--wait=0 --speed=1` để thấy nền móng và thợ đang khuân/gõ. Có bảng soi riêng bộ 01, 5 nét mặt, các tư thế đi/chặt/hái/khuân/ngủ/biển/câu/ăn/đội mũ, và các bộ cũ ghép chung; tự mở các ảnh ở ba thời điểm.
- Ảnh nằm trong `build/art-review/2026-10-03/` (được gitignore): `before/` và `after/` chứa bộ chụp chuẩn; `after/site-early/construction.png` chứa móng còn đang xây; `after/rig_0.2.png`, `rig_0.5.png`, `rig_0.8.png` là bảng soi thổ dân. Script bảng soi chỉ nằm cùng thư mục build, không thuộc mã game.

### Cách xem thử
- Mở ảnh `before/levels.png` và `after/levels.png` để so góc mái; `after/village_zoom_1.png` để xem cạnh nhà cũ; `after/site-early/construction.png` để xem móng; `after/rig_0.8.png` để xem bộ thổ dân và mảnh cũ ghép chung.
- Trong editor chạy game, xây Lều rồi nâng lên cấp 2/3; phóng to để nhìn sống mái/cửa thấp. Giao dân chặt cây/hái quả/nhặt sỏi/xây nhà, nhìn khớp vai/chân và đồ khuân; cho nghỉ hoặc thiếu đồ để nhìn tư thế ngủ/biển.

### Còn biết & số nên chỉnh
- Đây là góc vẽ cách điệu khoảng 50–60°, chưa đồng nhất toàn bộ cảnh: nhà/mảnh tóc-thân cũ vẫn giữ hướng vẽ cũ theo phạm vi thử. Bộ 01 cao khoảng 62 px trước scale, ~40 px trong thế giới, nét mặt khó đọc khi zoom xa; các thân cũ cao hơn bộ 01 khoảng 4 px.
- Số hình ảnh để duyệt: `top` mái lều 94/76/58 px và sống mái trước y=214 trong generator; vai y=-25, cổ y=-27, hông y=-12, `HAND_DISTANCE=11`, `CARRY_HEAD_TOP=-57`, `SIGN_RAISED_POS.y=-46` trong rig. Không chỉnh số cân bằng game.

---

## Sau Đợt D — Chốt góc vẽ, chuẩn bị giao Codex vẽ lại hình (2026-10-03)

**Trạng thái:** chỉ tài liệu, chưa vẽ lại gì — chưa commit.

- **Chốt góc vẽ** (GAME_DESIGN mục 7, ASSET_SPEC): 3/4 nhìn từ trên cao ~50–60°, không xoay, như Prehistoric Tribes; không isometric, không 3D. Hình tạm hiện tại còn gần nhìn ngang → vẽ lại dần: thử **lều 3 cấp + móng 2x2 + một bộ thổ dân** (head_01, face_01_*, hair_01, body_01, arm, leg) trước, duyệt xong mới vẽ hết (công trình, thổ dân, thú, mỏ tài nguyên, cây cỏ trang trí, đồ cầm tay, vách đá chỉnh `FACE_HEIGHT` / `TOP_DEPTH_SCALE`).
- **Thêm `AGENTS.md`** (bản copy của CLAUDE.md cho Codex, thêm một dòng đầu). Từ giờ sửa GAME_DESIGN.md thì copy sang cả CLAUDE.md lẫn AGENTS.md.
- Việc vẽ lại giao cho Codex (gợi ý: GPT-6.1 Sol, mức suy nghĩ High), theo 2 prompt: làm thử → làm hết. Chỉ đụng hình (SVG, script sinh hình, `art_specs.gd`, ASSET_SPEC, hằng vị trí bộ khung thổ dân nếu cần), không đụng lõi game.
- Sau phần hình: quay lại kế hoạch chính, **Đợt 4 — tìm bạn đời & dân số**. Hoạt cảnh mới viết thành chuỗi trạng thái có tên để sau này đổi đồ hoạ (kể cả nếu có lúc chuyển 3D) chỉ phải làm lại phần diễn.

---

## Đợt D — Cảm giác Prehistoric Tribes (hướng A: giữ 2D) (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Bàn trước khi làm
- So với AoE: AoE là **isometric** (ô thoi, nhà nhìn chéo thấy 2 mặt tường), lính nhỏ, đông, hình dựng từ 3D 8 hướng. Game mình và **Prehistoric Tribes đều là 2D nghiêng 3/4, ô vuông** — không cần isometric hay 3D. Cảm giác "RimWorld" chủ yếu do **người to, cảnh thưa, nhà không có sân**. Chốt: giữ 2D (nhẹ máy), làm theo cảm giác Prehistoric Tribes. (3D low-poly để ngỏ cho sau MVP nếu cần.)

### Đã làm
- **Thổ dân nhỏ lại** còn 65% (`VILLAGER_SCALE`, nhân vào `age_scale`), thú 70% (`ANIMAL_SCALE`). Bong bóng / icon trên đầu ×1,3 và tấm biển ×1,35 để không nhỏ theo; vùng chạm tối thiểu bán kính 24 px.
- **Sân đất + vòng đá quanh mỗi công trình** (kể cả móng): sân rộng hơn chân nhà một vòng (góc bo), vòng đá thấp (`world/yard_ring.gd`, vẽ bằng code) chừa lối vào ở cạnh trước; nhà sát nhau thì gộp thành một khu, đá nằm trong sân nhà khác bị bỏ. Cây cỏ trong sân bị giấu. Huỷ móng thì sân mất.
- **Sân làng** đất quanh hang + lửa trại (thay mảng đất "sân làng" cũ).
- **Cây cỏ trang trí phủ kín map**: thêm dương xỉ, cỏ cao, bụi lá (không quả), lau sậy ven hồ, nấm dưới tán (`tools/gen_decor_art.py`) cùng hoa, khóm cỏ cũ. Rậm thưa theo nhiễu (đám rậm xen bãi trống), gần rừng / ven hồ rậm hơn. Vẽ **màu chìm, viền xanh** để khác hẳn mỏ tài nguyên. Hơn 4.000 cây cỏ vẽ bằng `DecorLayer` (MultiMesh, mỗi loại hình một lệnh vẽ), lay theo gió.
- **Lối mòn có sẵn** từ sân làng ra cây, đá tảng, bụi quả, bãi sỏi, đống củi, chỗ câu cá gần làng nhất (theo đường đi trên lưới).
- **Đường mòn tự hình thành**: mỗi lần thổ dân bước sang ô mới thì ô đó mòn thêm 5%; khoảng 20 lượt đi qua thành đường đất rõ; bỏ không ~8 phút thì cỏ mọc lại. Lưu cùng ván (`SaveGame.VERSION` = 7).
- **Một lớp đất trơ cho cả map** (`GroundMask` + `fx/ground_mask.gdshader`): ảnh nhỏ mỗi ô một điểm ảnh, phóng to + nhiễu thành mảng đất mép lởm chởm — sân và đường mòn chỉ tốn một lệnh vẽ.
- Hoa bị sân đè thì không còn để hái.
- Test: thêm `test_prehistoric_look` (cây cỏ phủ map, lối mòn có sẵn, người nhỏ mà vùng chạm đủ to, đặt lều thì có sân và cây cỏ bị dọn, giẫm nhiều thì mòn, lưu / tải giữ đường mòn). 78/78, soi cảnh báo strict sạch.
- **Tốc độ** (máy này, tắt vsync): zoom 1 ~500 khung/giây (~1.050 lệnh vẽ), zoom 0,8 ~394 (~1.120), thu nhỏ hết cỡ ~164 (~3.380). Chậm hơn Đợt C khoảng 10–20%.

### Còn biết
- Thổ dân nhỏ thì khó nhìn nét mặt / đồ cầm tay hơn khi nhìn xa; có thể cần zoom mặc định gần hơn (`CAMERA_ZOOM_DEFAULT`).
- Vòng đá là đá rời vẽ bằng code, chưa phải hàng rào / tường đá như game gốc.
- Cây cỏ trang trí không đổ bóng; bị nhà đè thì giấu hẳn (huỷ móng không hiện lại).
- Đường mòn chỉ tính theo ô nên thẳng góc ở chỗ rẽ (nhờ nhoè + nhiễu nên đỡ thấy).

### Số nên tinh chỉnh (`data/balance.gd`)
- `VILLAGER_SCALE` 0,65, `ANIMAL_SCALE` 0,7, `OVERHEAD_SCALE` 1,3, `SIGN_SCALE` 1,35, `MIN_PICK_RADIUS` 24.
- `DECOR_SPARSE` / `DECOR_DENSITY` 0,12 / 1,8, `MEADOW_DECOR` 0,8, `VILLAGE_DECOR_CLEAR` 3.
- `YARD_MARGIN_CELLS` 0,75, `VILLAGE_YARD_RADIUS` 3,4.
- `WEAR_PER_STEP` 0,05, `WEAR_DECAY_SECONDS` 10 / `WEAR_DECAY` 0,985, `TRAIL_WEAR` 0,6, `TRAIL_FLOOR` 0,5.

---

## Đợt C.3 — Tài nguyên kiểu RTS: mỏ có lượng, nhiều người làm chung (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Mỗi chỗ tài nguyên là một mỏ có lượng** (`ResourceNode.amount / capacity`, tính bằng món): bụi quả to 30 thức ăn, bãi sỏi 20 đá, đống củi 15 gỗ, đá tảng 16 đá, cây 3 khúc gỗ. **Nhiều người làm chung** (bụi 3, sỏi / củi / đá tảng 2, cây 1): Reservations nhận `capacity`, mỗi người một chỗ đứng quanh mỏ (`claim_stand`, ô đã có người bị phạt khi chọn chỗ). Thổ dân **làm liền ở cùng mỏ** tới đầy giỏ / bó / xô rồi mới khuân về (hái quả giờ cũng theo mẻ: 3 nắm = 6 thức ăn).
- **Hình theo lượng còn lại** > 50% / 20–50% / < 20% (`_100/_50/_20`): bụi quả (9 / 4 / 2 chùm quả + bụi trụi), bãi sỏi (18 / 9 / 4 viên), đống củi (12 / 6 / 3 cành), đá tảng to / nhỏ (nguyên → sứt mẻ → mẩu nhỏ). Hình tạm sinh bằng `tools/gen_resource_art.py`; bỏ hình cũ `rock_big/small`, `bush_berries`, `twigs`, `pebbles`.
- **Thanh lượng chỉ trong bảng thông tin** (click vào vật): thanh xanh / vàng / đỏ + "Còn X/Y" (quy ra tài nguyên chung). Không vẽ gì trên map.
- **Bãi sỏi, đống củi sinh cùng map** (`_place_piles`): bãi sỏi cạnh bãi đá tảng (chân vách được cộng điểm), đống củi cạnh cây trưởng thành ở rừng rậm; 2 cái gần làng mỗi loại. Đi qua được (`MapData.LOOSE_KINDS`). Lúc mở ván mỗi mỏ lượng ngẫu nhiên (đá tảng 30–100%, còn lại 50–100%).
- **Bụi quả to**, mỗi vạt 2–3 bụi sát nhau. Hái trụi thì **60 ngày** sau mới đầy lại (`BUSH_REGROW_DAYS`).
- **Cây lớn dần**: `growth` 0 → 1 trong 2 ngày, cây non vẽ nhỏ (40% → 100%), chưa chặt được; ~12% cây lúc mở ván là cây non (nhiều ở bìa rừng); gốc mọc lại thành cây non.
- **NatureSpawner viết lại**: cây trưởng thành rụng 3 gỗ ~10 giây một lần vào đống củi cạnh nó (chưa có thì đống mới, tối đa 30 đống; cây trong rừng rậm hay rụng hơn); vách đá lở ~45 giây một lần ở chân vách phía trước: 40% một tảng đá (khi ít hơn lúc đầu), còn lại 8 sỏi dồn vào bãi gần đó (chưa có thì bãi mới, tối đa 30 bãi), có bụi đá.
- Chữ: "đá cuội" → "sỏi" (bãi sỏi, xô sỏi, nhặt sỏi), "củi khô" → "đống củi", bảng thông tin có dòng cây non / bụi chờ ra quả (tính theo ngày khi còn lâu).
- `SaveGame.VERSION` = 6. Công cụ chụp màn hình thêm `resources.png`, `panel_pebbles.png`, `panel_twigs.png`; sơ đồ map tô màu bãi sỏi / đống củi.
- Test: thêm `test_resource_patches` (hình theo lượng, bụi trụi chờ 60 ngày, 3 người hái chung một bụi mỗi người một chỗ, bãi sỏi hết thì biến mất, cây non chưa chặt, vách lở ra sỏi ở chân vách); sửa các test dùng cơ chế cũ. 77/77, soi cảnh báo strict sạch.

### Quyết định
- Bụi quả hồi **60 ngày tính từ lúc hái trụi** (mỗi bụi một đồng hồ), không phải cả map cùng đầy một lúc.
- Hái quả thêm mẻ 3 nắm (trước khuân 2 quả mỗi chuyến) để đỡ chạy đi chạy về — đúng tinh thần "đỡ hỗn loạn".
- Thanh lượng tính theo tài nguyên chung (cây: "Còn 20/30" gỗ thay vì "2/3 khúc").

### Còn biết
- 60 ngày = 4 tiếng chơi thật (một ngày 4 phút) — gần như mỗi bụi chỉ hái được một lần mỗi buổi chơi; thức ăn lâu dài phải trông vào câu cá, săn thú.
- Dòng "Mỗi lượt (~3 giây): 2 thức ăn" trong bảng thông tin là một nắm, chưa nói rõ "3 nắm mới khuân về".
- Đống củi / bãi sỏi trên nền cỏ vẫn hơi nhỏ khi thu nhỏ hết cỡ.

### Số nên tinh chỉnh (`data/balance.gd`)
- Lượng / người: `BUSH_FOOD` 30 / `BUSH_WORKERS` 3, `PEBBLE_PATCH_STONE` 20, `TWIG_PILE_WOOD` 15 / `PILE_WORKERS` 2, `ROCK_STONE` 16 / `ROCK_WORKERS` 2.
- `BUSH_REGROW_DAYS` 60, `GATHER_PICK_BATCH` 3, `LOOSE_PICK_BATCH` 3.
- `TREE_GROW_SECONDS` 2 ngày, `YOUNG_TREE_CHANCE` 0,12, `YOUNG_TREE_SCALE` 0,4.
- `PEBBLE_PATCHES` 22, `TWIG_PILES` 20, `STARTER_PILES` 2, `TWIG_DROP_SECONDS` 10 / `TWIG_DROP_AMOUNT` 3 / `TWIG_PILE_MAX` 30, `CLIFF_SLIDE_SECONDS` 45 / `CLIFF_SLIDE_BOULDER_CHANCE` 0,4 / `CLIFF_SLIDE_PEBBLES` 8 / `PEBBLE_PATCH_MAX` 30.
- `RESOURCE_STAGE_HALF/LOW` 0,5 / 0,2, `START_AMOUNT_MIN` 0,5, `ROCK_START_AMOUNT_MIN` 0,3.

---

## Đợt C.2 — Vách đá thành bức vách liền, đá chỉ ở chân vách (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Vách đá vẽ bằng code thành một bức vách liền** (`world/cliff_ridge.gd`), bỏ 4 hình khối `env/cliff_rock_0N` (và phần sinh hình trong `tools/gen_building_art.py`). Mỗi dãy: mặt đứng cao 92 px quay về phía người nhìn (tối dần xuống chân, vân nứt dọc), mặt trên co lại một nửa bề dày ô (nhìn xiên — vách trông dựng đứng, không thành cao nguyên), mép đỉnh lởm chởm, vài búi rêu và vệt đá, đá vụn dưới chân; viền chỉ ở mép ngoài nên không còn thấy từng khối. Hai đầu dãy thấp dần; chỗ chân vách dịch hàng thì đường biên uốn mượt.
- Mỗi cột ô vách là một node trong Entities (gốc ở chân vách) để y-sort: ai đi phía sau vách bị che, ai đứng trước vách vẽ đè lên vách. Bóng cả dãy là một đa giác ở ShadowLayer (quét theo chiều cao vách, cùng màu với bóng khác), chỉ vẽ lại khi mặt trời đổi đủ nhiều.
- **Dãy vách chạy ngang là chính** (mặt đứng quay về phía người nhìn mới ra "bức vách"): đi từng cột sang trái / phải, chân vách trôi lên / xuống dần theo một hướng nghiêng, dày 1–2 ô; dài 8–16 cột (trước 6–14 ô). Mỗi cột là một đoạn ô liền, cột cạnh nhau luôn chạm cạnh (không có khe chéo).
- **Bãi đá tảng chỉ ở chân vách phía trước** (3 hàng dưới chân: 85% / 40% / 16%), không còn ở phía sau. Đá tảng mới cũng chỉ lăn ra phía trước. Đá tảng / đá cuội / củi không rơi vào ô ngay sau lưng vách (`_behind_cliff`). **Đá cuội ưu tiên bãi đá chân vách** (cộng điểm `CLIFF_FOOT_BONUS` khi chọn nguồn).
- `SaveGame.VERSION` = 5. Công cụ chụp màn hình chụp thêm `cliff_far.png`.
- Test: đếm node theo cột vách + kiểm tra mỗi cột là đoạn liền; test 3 thợ chặt + 2 thợ đập đá dựng thêm một Kho cạnh bãi đá chân vách (bãi giờ xa làng) và cho phép một phút sản lượng đứng yên (cả nhóm đi ăn / ngủ). Sửa 3 test thỉnh thoảng trượt do may rủi: tán gẫu (ai bắt chuyện trước cũng được, chờ 4 phút), gục ngủ / ngất (chờ tới khi dậy, giới hạn rộng hơn), chạm chọn thổ dân (chọn người không bị ai đứng chồng). Chạy cả bộ 3 lần liền: 76/76.

### Còn biết
- Dãy vách chéo nhiều bậc thì mặt đứng thành bậc thang (mỗi cột lệch một hàng) — trông như vách gãy khúc, chấp nhận được.
- Vách không còn là file hình nên muốn thay art thật phải sửa code vẽ (ghi trong ASSET_SPEC).
- Bãi đá chân vách nằm xa làng: khai thác đá lâu dài nên xây thêm Kho gần đó.

### Số nên tinh chỉnh
- `cliff_ridge.gd`: `FACE_HEIGHT` = 92, `TOP_DEPTH_SCALE` = 0,5, `PEAK_HEIGHT` = 14, `END_TAPER` = 56, các màu `TOP_*` / `FACE_*`.
- `balance.gd`: `CLIFF_RIDGE_MIN/MAX_LENGTH` = 8/16, `CLIFF_TURN_CHANCE` = 0,35, `CLIFF_THICK_CHANCE` = 0,6, `RIDGE_SCREE_NEAR/FAR` = 0,85/0,4.
- `nature_spawner.gd`: `CLIFF_FOOT_BONUS` = 5.

---

## Đợt C.1 — Tài nguyên trông tự nhiên hơn (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Bãi đá tảng liền dọc chân vách** (`_place_ridge_scree`): chọn một đoạn 55–85% dãy vách; ô sát vách 85% có đá (đá to nhiều), ô cách 2 ô 40% (đá nhỏ nhiều), hai đầu đoạn thưa dần, phía trước vách (nam) nhiều hơn phía sau; tối đa 16 tảng mỗi dãy. Không đặt trong 2 ô quanh dãy khác để giữ lối đi.
- **Bãi đá lẻ gom chặt**: ô gần tâm được chọn trước (cộng chút ngẫu nhiên cho hình méo), đá to ở giữa.
- **Rừng méo tự nhiên**: mỗi cánh rừng ghép 1 khối chính + 0–3 khối phụ, bìa gợn theo nhiễu, cây lẻ lấn ra ngoài bìa (tới 1,6 lần bán kính). Loại cây theo **mảng** nhiễu thấp tần (mảng thông, mảng cây lá tròn). Thêm 14 lùm 1–3 cây lẻ trên bãi cỏ.
- Cây và đá tảng **lệch nhẹ khỏi tâm ô** (cây ±14/±9 px, đá ±9/±6 px) — lưu trong `MapData.objects[i].jitter`.
- **Đá cuội nhiều hơn và gom đám**: mở ván 60 viên (trước 16), tối đa 100 (trước 30), lăn thêm ~8 giây. **Củi** mở ván 30, tối đa 50. Món mới 65% rơi cạnh món cùng loại có sẵn (vẫn phải trong 2,3 ô quanh đá tảng / 1,5 ô quanh cây); còn lại rơi quanh nguồn nằm trong cụm dày nhất trong 5 nguồn bốc ngẫu nhiên → dồn về bãi đá lớn / rừng rậm. **Rải sẵn 8 củi + 8 đá cuội quanh cụm gần làng** (vì cụm nhỏ ít được chọn) để ván mới tay trắng vẫn có đồ nhặt gần nhà.
- `SaveGame.VERSION` = 4 (map sinh khác → save của Đợt C bị từ chối).
- Test `test_three_choppers_two_miners` giờ giao đá ở bãi chân vách: bãi gần làng chỉ có 6 tảng, 2 người đập hết đúng trong 5 phút rồi (đúng luật) cắm biển "hết đá".

### Còn biết
- Mỗi ô chỉ một đám củi / đá cuội nên bãi đá cuội vẫn hơi thưa khi nhìn gần; muốn dày hơn thì cần hình "đống đá cuội" nhiều viên hơn.
- Bãi đá gần làng (6 tảng ≈ 96 đá) cạn sau vài phút đập — sau đó phải đi xa tới chân vách.

### Số nên tinh chỉnh
- `RIDGE_SCREE_NEAR/FAR` = 0,85/0,4, `RIDGE_SCREE_SPAN_MIN/MAX` = 0,55/0,85, `RIDGE_BOULDERS_MAX` = 16.
- `FOREST_BLOBS_MAX` = 3, `FOREST_EDGE_WOBBLE` = 0,3, `FOREST_STRAY_CHANCE` = 0,06, `LONE_COPSES` = 14, `TREE_JITTER` / `ROCK_JITTER`.
- `PEBBLE_START/MAX` = 60/100, `PEBBLE_SPAWN_SECONDS` = 8, `TWIG_START/MAX` = 30/50, `LOOSE_CLUMP_CHANCE` = 0,65, `PEBBLE_FIELD_RADIUS` = 2,3, `STARTER_LOOSE` = 8.

---

## Đợt C — Map rộng kiểu RTS, tài nguyên theo cụm, dãy vách đá (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Map 96×72 ô** (gấp 4 diện tích). Mở game nhìn xa hơn (zoom 0.8), thu nhỏ được tới 0.35.
- **Bộ sinh map viết lại theo kiểu RTS** (`world/map_generator.gd`):
  - Rừng thành **11 cánh rừng** (8 cánh dồn về phía rừng, 3 cánh lẻ): lõi dày, bìa thưa, nhiễu tạo khoảng trống và lối đi.
  - **6 dãy vách đá** (5 dãy phía bãi đá, 1 dãy chỗ khác): đi ngoằn ngoèo 6–14 ô, dày 1–2 ô, cách nhau ít nhất 3 ô nên luôn có lối đi; dưới chân mỗi dãy 3–6 đá tảng. Thêm 4 bãi đá tảng lẻ.
  - Bụi quả mọc thành **vạt** 3–5 bụi: một vạt gần làng, một vạt trong đồng cỏ, 6 vạt rải quanh map.
  - **Gần làng có sẵn một cụm nhỏ mỗi loại**: lùm cây (cách làng 8–11 ô về phía rừng), 6 đá tảng (về phía bãi đá), một vạt bụi quả.
  - Hồ lớn hơn, 7 chỗ câu cá; đồng cỏ rộng hơn, 8 con thú. Củi / đá cuội tối đa 40 / 30.
- **Vách đá giờ là địa hình**, không còn là "công trình" 3×2: `MapData.cliffs` = các ô vách (chặn đường). Mỗi ô một **khối vách** (`env/cliff_rock_01..04`, chọn ngẫu nhiên theo ô, có lật ngang) rộng gần 2 ô nên các khối chồng lên nhau thành bức vách liền: đỉnh lởm chởm sáng, mặt đứng có vân dọc, phía phải tối, rêu trên đỉnh. Nằm trong lớp Entities (người đi sau vách bị che), có bóng đổ theo mặt trời. Đá tảng mới lăn ra sát chân dãy vách.
- **Save cũ không tải được nữa** (map sinh khác hẳn): `SaveGame.VERSION` = 3, bấm Tải ván cũ thì báo "Ván lưu từ bản cũ…".
- Công cụ mới `tools/map_preview.tscn`: vẽ sơ đồ toàn map ra PNG (mỗi ô một ô màu). Công cụ chụp màn hình chụp thêm `cliff.png`.
- **Tốc độ** (máy này, tắt vsync, camera trượt): zoom 0.8 ~440 khung/giây (~810 lệnh vẽ), thu nhỏ hết cỡ 0.35 ~200 khung/giây (~3.000 lệnh vẽ).
- Test: 76 test (thêm: map đúng cỡ, có vách đá chặn đường, gần làng đủ cụm cây/đá/bụi, cây mọc thành cụm). Sửa test cũ theo map mới. Soi cảnh báo strict: sạch.

### Quyết định
- Giữ "rừng một phía, đá phía đối diện, hồ trên/dưới, đồng cỏ phía còn lại" nhưng rải thêm vài cánh rừng / dãy vách ở chỗ khác cho map đỡ đơn điệu.
- Cây, đá kẹt không tới được vẫn bị bỏ khi sinh map (lõi rừng quá dày) — vì vậy mật độ lõi rừng giữ ≤ 0,45.
- Vách đá không chạm/chọn được (không có bảng thông tin), con trỏ hiện ✕ khi đang chọn người.

### Còn biết
- Khối vách đá vẫn có viền riêng từng khối nên dãy vách nhìn hơi thành "cột" khi chạy dọc; art thật nên vẽ liền mạch hơn.
- Thu nhỏ hết cỡ có ~3.000 lệnh vẽ — máy yếu / bản Web có thể chậm; cần đo trên điện thoại ở Đợt 6.
- Map rộng nên thổ dân đi xa hơn tới cụm giàu; cụm gần làng sẽ cạn sau vài phút (đúng tinh thần RTS).

### Số nên tinh chỉnh
- `MAP_WIDTH/HEIGHT` = 96/72, `CAMERA_ZOOM_DEFAULT` = 0,8, `CAMERA_ZOOM_MIN` = 0,35.
- Rừng: `FOREST_CLUSTERS` = 11, `FOREST_RADIUS_MIN/MAX` = 4,5/9, `FOREST_CORE_DENSITY` = 0,65, `FOREST_MAX_DENSITY` = 0,45.
- Vách: `CLIFF_RIDGE_COUNT` = 6, dài 6–14, `CLIFF_THICK_CHANCE` = 0,6, `CLIFF_RIDGE_GAP` = 3.
- Đá: `ROCK_FIELD_COUNT` = 4 (4–7 tảng), `STARTER_ROCKS` = 6, `RIDGE_BOULDERS_MIN/MAX` = 3/6.
- Bụi: `BERRY_GROVES` = 6 (3–5 bụi). Thú: `ANIMAL_COUNT` = 8.

---

## Đợt B — Điều khiển chuột kiểu AoE, khung chọn nhiều người, con trỏ đổi hình (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Chuột kiểu AoE** (`autoload/input_router.gd` viết lại, `NormalController` viết lại):
  - **Click trái = chọn** thổ dân / công trình / vật thể (không bao giờ ra lệnh). Shift + click: thêm / bớt người vào nhóm. Click chỗ trống: bỏ chọn.
  - **Kéo chuột trái = khung chọn** nhiều thổ dân (Shift: thêm vào nhóm đang chọn). Bỏ kéo chuột trái để trượt bản đồ và bỏ kéo-thả giao việc bằng chuột.
  - **Click phải = ra lệnh** cho những người đang chọn (vẫn giữ chọn sau khi ra lệnh). Lúc đang đặt nhà hoặc không chọn ai thì click phải = huỷ / bỏ chọn.
  - **Trượt bản đồ:** phím WASD / mũi tên, **chuột sát mép màn hình** (8 px), kéo **chuột giữa**. Lăn chuột zoom như cũ.
- **Ra lệnh cho nhóm** (`Commands.assign_group`, `Commands.move_group`): vào cây / đá / bụi… thì mỗi người nhận một cái gần nhau (không xúm một cây); vào công trình thì cùng vào (thừa người thì người thừa cắm biển); vào mặt đất thì mỗi người một ô quanh điểm đó (không đứng chồng).
- **Bảng nhóm** (`ui/common/group_panel.gd`): "Đang chọn N người", mỗi người một nút (icon việc đang làm + tên), bấm để chọn riêng người đó. Đường chấm chấm hiện cho cả nhóm.
- **Con trỏ đổi hình** (`ui/normal/command_cursor.gd`): đang chọn người mà rê chuột lên mục tiêu thì cạnh con trỏ có icon nhún nhún — bụi quả / chỗ câu cá → đồ ăn, cây → rìu, đá → cuốc, thú → giáo, củi → bó củi, đá cuội → xô, móng → búa, bếp → nồi, lò rèn → búa rèn, lều → Zzz, sân nhảy → mặt cười, mặt đất → cờ, chỗ không đi được → ✕. Dữ liệu: khoá `cursor` trong `data/jobs.gd`.
- **Cảm ứng giữ cách cũ** (điện thoại không có chuột phải): chạm chọn, đang chọn mà chạm mục tiêu / mặt đất thì ra lệnh rồi bỏ chọn, kéo một ngón trượt bản đồ, kéo từ thổ dân = kéo-thả giao việc, **nhấn giữ rồi kéo = khung chọn**.
- Đổi các dòng gợi ý ("Chọn thổ dân rồi click phải (hoặc chạm)…") và dòng hướng dẫn điều khiển ở bảng debug.
- Test: 75 test (viết lại test InputRouter: kéo trái = khung, kéo giữa = trượt, click phải = ra lệnh, cảm ứng kéo / nhấn giữ kéo; controller: click trái chỉ chọn, click phải ra lệnh + giữ chọn, icon con trỏ; kéo khung chọn 3 người → đi tới mỗi người một ô, chặt cây mỗi người một cây). Soi cảnh báo strict: sạch. Công cụ chụp màn hình thêm `--group`.

### Quyết định
- Click phải ra lệnh xong **giữ chọn** (như AoE) để ra lệnh tiếp; cảm ứng vẫn bỏ chọn sau lệnh (tránh lỡ chạm).
- Thổ dân chui vào lều ngủ thì tự rời khỏi nhóm đang chọn.
- Không đổi hình con trỏ hệ thống (giữ mũi tên), chỉ thêm icon nhỏ cạnh con trỏ — chạy được cả bản Web.

### Còn biết
- Khung chọn vẽ dưới thổ dân / cây (lớp mặt đất).
- Bảng nhóm tối đa vài chục nút; chọn cả làng 50 người thì bảng khá cao.
- Chuột sát mép màn hình cũng trượt khi chuột đang nằm trên thanh HUD ở mép trên (giống AoE).

### Số nên tinh chỉnh
- `CAMERA_EDGE_SCROLL_PX` = 8, `CAMERA_KEY_PAN_SPEED` = 700 (dùng chung cho trượt mép). `Commands.GROUP_SPREAD_MAX_RADIUS` = 6.

---

## Đợt A (sau Đợt 3) — Dân đứng yên khi rảnh, đá cuội thay cuốc, biển đè lên người, bảng thổ dân, gió (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit. (Đợt B: điều khiển chuột kiểu AoE; Đợt C: map rộng gấp 4, tài nguyên theo cụm, dãy vách đá.)

### Đã làm
- **Rảnh thì đứng yên tại chỗ được thả.** 30 giây đầu chỉ làm trò tại chỗ: đứng chờ, **vẫy vẫy người chơi** (hoạt họa mới), **ngó nghiêng** (quay qua quay lại), vươn vai, gãi, tán gẫu với người **đứng sát bên** (không ai bước đi tìm ai). Quá 30 giây mà chưa có việc thì **chán**: ngồi phịch, **nằm ngủ gật** tại chỗ 8–15 giây (task mới `TaskNap`, hồi chút sức), hoặc đi hái bông hoa trong 3 ô rồi **quay về đúng ô cũ**. Bỏ hẳn đi dạo (xoá `TaskStroll`). Lười hay ngồi / ngủ gật, Ham chơi hay vẫy tay.
- **Đá:** bỏ "đá nhỏ nhặt tay" (Đợt 3.1) — đá tảng to hay nhỏ đều cần cuốc. **Giao đập đá tảng mà làng chưa có cuốc → tự nhặt đá cuội nằm trong 3 ô quanh tảng đá đó** (nghĩ tới cái cuốc cho người chơi biết); không có đá cuội mới cắm biển cuốc (không gạch chéo). Đang đập đá mà cuốc bị lấy hết cũng tự chuyển như vậy. Viết dạng dữ liệu (`fallback_job` trong `data/jobs.gd`) để sau này việc khác dùng lại.
- **Tấm biển vẽ đè lên người** (tay, đầu, đồ cầm không che hình trên biển).
- **Bảng thổ dân gọn lại** (cao chỉ còn ~một nửa): chân dung nhỏ hơn; tên + mặt tâm trạng + giới tính một dòng; tính cách thành **thẻ nhỏ** (giải thích trong tooltip); bên dưới trái 4 chỉ số xếp dọc (icon + thanh), phải kỹ năng dạng lưới 4 cột (icon + **số cấp** — bỏ hàng sao; việc thích là ô có **khung viền vàng + nền vàng nhạt** thay cho trái tim).
- **Gộp Săn bắn + Chiến đấu thành một kỹ năng** "Săn bắn & chiến đấu" (id `FIGHT`, icon cây giáo): đi săn luyện kỹ năng này; Đợt 5 dùng nó cho sát thương cận chiến lẫn ném giáo. Còn 8 kỹ năng. Save cũ có kỹ năng "HUNT" tự đổi sang (lấy cấp cao hơn), việc thích "HUNT" cũng vậy. Icon thể lực đổi thành **Zzz**; icon giải trí là **mặt người đổi theo mức**: vui (≥ 60), bình thường (≥ 30), bực bội đỏ cả mặt (thấp hơn — cũng là icon nhấp nháy trên đầu khi sắp đình công).
- **Gió cố định** ở mức vừa (bỏ gió giật ngẫu nhiên). Sửa luôn lỗi gốc của gợn sóng: shader mặt hồ nhân `thời gian × sức gió`, nên game chạy lâu thì mỗi lần sức gió đổi chút xíu là gợn sóng giật vọt — giờ tốc độ trôi không phụ thuộc sức gió.
- Test: 72 test (thêm: đứng yên 30 giây đầu rồi mới chán + tán gẫu tại chỗ; không cuốc thì nhặt đá cuội cạnh tảng đá / không có thì cắm biển không gạch chéo). Test làng sống 5 phút giờ kiểm tra hoạt cảnh tại chỗ phải đứng **đúng ô** điểm neo. Soi cảnh báo strict: sạch.

### Quyết định
- "Đá cuội cạnh tảng đá" = trong 3 ô quanh tảng đá (đá cuội vốn lăn ra sát đá tảng).
- Ngủ gật lúc chán là việc rảnh: giao việc là dậy ngay; mệt thật (< 50%) thì vẫn đi tìm lều như cũ.
- Nhiều người cùng được thả một chỗ thì đứng chồng một ô — Đợt B (ra lệnh cho nhóm) sẽ tản họ ra.

### Số nên tinh chỉnh
- `IDLE_BORED_SECONDS` = 30, `NAP_MIN/MAX_SECONDS` = 8/15, `IDLE_RADIUS_CELLS` = 3 (bán kính đi hái hoa), `IDLE_CHAT_RANGE_CELLS` = 1,6.
- `TOOL_FALLBACK_RADIUS_CELLS` = 3. `Wind.STRENGTH` = 0,6. `FUN_FACE_HAPPY/OK` = 60/30.

---

## Đợt 3.1 — Đá nhỏ nhặt tay, biển "cần cái này", bảng thông tin vật thể (2026-10-03)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Đá nhỏ nhặt bằng tay** (việc mới `pick_rock`, kỹ năng Hái lượm): chạm đá nhỏ → thổ dân cúi nhặt, giơ đá trên đầu khuân về; 4 giây → 2 đá, mỗi viên 2 lượt. Đá tảng to vẫn cần cuốc. Người đang đập đá bằng cuốc mà quanh đó hết đá to thì đập luôn đá nhỏ (khỏi dừng việc sớm vì đá to giờ chỉ ~40% số đá).
- **Tấm biển "thiếu đồ nghề / nguyên liệu" bỏ dấu ✕** — chỉ vẽ món đang cần: thiếu rìu/cuốc/giáo, thiếu gỗ/đá để xây hay rèn, bếp chưa có gì để nấu. Dấu ✕ chỉ còn cho "hết rồi / không làm được": hết cây/đá/quả/thú, kho đầy, đủ người, lều hết chỗ, đình công. Nhờ vậy "cần rìu" (rìu) và "hết cây" (rìu ✕) không còn trông giống hệt nhau.
- **Bảng thông tin vật thể** (`ui/common/object_panel.gd`): không chọn thổ dân mà chạm cây, gốc cây, đá tảng, đá nhỏ, bụi quả, củi, đá cuội, chỗ câu cá, con thú → bảng góc dưới-trái: hình, tên, mô tả, mỗi lượt ra gì (bao nhiêu, mấy giây), còn mấy lượt, cần đồ nghề gì (làng đang có mấy / chưa có thì xây Lò rèn) hay làm bằng tay, bụi hết quả thì còn bao lâu ra quả lại, gốc cây, ai đang làm ở đó, gợi ý cách giao việc. Vật đang xem có vòng vàng dưới chân. Chạm lại / ✕ / chạm chỗ trống thì đóng; củi nhặt mất, thú bị săn thì bảng tự đóng.
- **Watchdog** không đếm thời gian đang đi đường nữa (đi rừng ↔ kho xa không phải kẹt) — trước đó test "3 chặt 2 đập" thỉnh thoảng trượt vì vậy.
- Test: 71 test (thêm: đá nhỏ nhặt tay + biển không/có ✕; chạm bụi / cây / thú hiện bảng, chạm lại thì đóng). Test cũ giao "đập đá" giờ nhắm đá tảng to. Soi cảnh báo strict: sạch. Công cụ chụp màn hình `--ui` chụp thêm `panel_bush/tree/rock.png`.

### Quyết định
- "Đá nhỏ" = hình đá tảng cỡ nhỏ có sẵn trên map (khác đá cuội nằm lẫn trên đất). Nhặt tay ra ít đá hơn đập đá to (4 đá vs 16 đá mỗi viên).
- Bảng vật thể chỉ để xem, không có nút giao việc — vẫn giao bằng cách chọn thổ dân rồi chạm (đúng kiểu game gốc).

### Số nên tinh chỉnh
- `SMALL_ROCK_USES` = 2, `STONE_PER_SMALL_ROCK` = 2, `SMALL_ROCK_PICK_SECONDS` = 4.
- `ROCK_BIG_CHANCE` = 0,4 (tỉ lệ đá to khi sinh map) — muốn nhiều đá phải dùng cuốc hơn thì tăng lên.

---

## Đợt 3 — Xây dựng, nâng cấp, ngày đêm & lưu game (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
**1. Xây dựng cơ bản**
- **Nút Xây** (cái búa, góc dưới-phải) mở menu 5 công trình (hình, tên, một dòng giải thích, giá cấp 1, diện tích). Chọn một cái → **bóng mờ đúng diện tích** (ô xanh/đỏ + hình công trình mờ). Chuột: bóng đi theo con trỏ, click là đặt. Cảm ứng: chạm để dời bóng, chạm lại đúng chỗ hoặc bấm ✓ để đặt. Thanh gợi ý dưới màn hình có nút ✕ (Esc / chuột phải cũng huỷ). Đặt xong mở luôn bảng của móng + thông báo "Đã đặt móng…".
- **Luật đặt** (`world/building_placer.gd`): trong map, không nước / cây / đá / công trình khác; củi, đá cuội nằm đó thì dọn đi; thú đứng đó thì chờ; người đứng đó thì nhảy sang ô bên. **Không chặn lối:** mọi ô đang đi tới được phải vẫn đi tới được (không quây kín vùng nào) và mọi công trình vẫn có lối vào.
- **Thợ xây** (`TaskBuild`): chạm/kéo thổ dân vào móng → **đội mũ công trường**, ra kho gần nhất lấy một chuyến (10 gỗ hoặc 5 đá, khúc gỗ / xô đá trên đầu), khuân đổ vào công trường, lặp lại tới khi **đủ vật liệu mới gõ búa**. Tối đa max(1, số ô ÷ 2) thợ, mỗi thợ một chỗ đứng quanh công trình; hứa trước phần đang khuân để không khuân thừa. Kho hết loại cần thì đứng trước công trình **cắm biển gỗ/đá ✕**, chờ rồi thử lại (không bỏ việc). Xây xong mà gần đó không còn công trình dở → **nhảy cẫng ăn mừng**, bỏ mũ. Bị ngắt giữa đường thì vật liệu đang khuân được cất lại kho.
- **Hiệu ứng:** móng (nền đất + cọc + dây), hình công trình mờ **mọc dần từ dưới lên** theo tiến độ (shader `fx/build_reveal.gdshader`), **hai thanh tiến độ** trên đầu (vật liệu, gõ búa), xong thì **nảy "bụp" + khói + pháo giấy** + thông báo. Đang nâng cấp thì cắm giàn giáo.
- **Bảng công trình** (`ui/common/building_panel.gd`, chạm công trình khi không chọn thổ dân): hình, tên, sao cấp, mô tả / trạng thái, vật liệu đã khuân / cần + 2 thanh tiến độ + số thợ, người phụ trách (hoặc cảnh báo + gợi ý cách giao), chỗ ngủ + ai đang ngủ, chỗ cất góp cho làng, món chín, đơn rèn, nút **Nâng lên cấp N** (kèm giá) và **Huỷ móng / Huỷ nâng cấp** (trả lại vật liệu đã khuân tới). Chỉ dựng lại phần nào thật sự đổi để không nuốt mất cú bấm.
- **Nâng cấp 3 cấp:** thành công trường, cần thợ xây khuân vật liệu như xây mới; **trong lúc đó vẫn hoạt động ở cấp cũ** (đầu bếp / thợ rèn làm tiếp). Chạm công trình đang nâng cấp = giao việc xây.

**2. Công trình chức năng**
- **Hang đá = kho tạm** (theo ý bạn): 30 gỗ, 30 đá, 15 thức ăn thô. **Lửa trại chỉ cất món chín** (4), một người nấu.
- **Kho chung có sức chứa** cộng dồn (`GameState.capacity/room`, World tính từ hang đá + Kho + Bếp). HUD hiện "đang có /sức chứa", đầy thì chữ đỏ, tooltip nhắc xây Kho/Bếp. Kho đầy: khuân về được phần nào hay phần đó, cắm biển **cái kho ✕** rồi thôi việc (lượt sau không làm nữa).
- **Lều:** 2 / 3 / 4 chỗ, hồi sức ×1.5 / ×2 / ×2.5. Mệt thì tự tìm lều gần nhất còn chỗ, **chui vào trong** (ẩn, lều rung nhẹ, bay Zzz), ngủ đủ chui ra vươn vai; hết chỗ thì ngủ đất cạnh lửa trại như cũ. Thả thổ dân vào lều = đi ngủ ngay (việc đang giao vẫn nhớ); lều đầy thì cắm biển Zzz ✕.
- **Bếp:** cất thêm 30 / 60 / 120 thức ăn thô, đầu bếp 1 / 2 / 3, nấu 5 giây một món (mỗi đầu bếp một nồi), món chín cất tại bếp 6 / 10 / 16 bát (bày quanh bếp). Dân đói tới chỗ có món chín trước, hết thì ăn đồ thô ở Bếp / hang đá.
- **Kho:** cộng 100 / 200 / 400 gỗ và đá.
- **Lò rèn:** thợ rèn 1 / 2 / 3; bảng −/+ đặt số rìu / cuốc / giáo còn muốn rèn (tối đa 9), thợ rèn làm lần lượt từng loại, lấy vật liệu từ kho lúc bắt đầu mỗi món (thiếu thì cắm biển gỗ/đá ✕), rèn xong "bụp" + món đó dựng cạnh lò đúng số lượng (rìu trái, cuốc giữa, giáo phải). Thổ dân lấy / đổi đồ nghề ở lò rèn như mục 9.4; món cũ luôn được trả lại (kể cả lò đầy). **Bỏ phím F10** (`Commands.debug_give_tools()` chỉ còn cho test / công cụ).
- **Sân nhảy:** xây / nâng cấp được, **đi lên được** (không chặn đường); thả thổ dân vào thì lên đứng chơi trên sân (disco để Đợt 4).
- **Thiếu người phụ trách:** Bếp / Lò rèn đã xây mà không ai phụ trách thì ngừng + **icon cảnh báo trên mái** + dòng đỏ trong bảng. Chạm công trình sản xuất đã đủ người thì thổ dân cắm biển icon việc ✕.
- Hình tạm mới: 15 hình công trình (5 × 3 cấp), 3 cỡ móng, mũ công trường, icon cảnh báo / kho / nâng cấp / ✓ / lưu / tải, mặt trời / mặt trăng, pháo giấy — sinh bằng `tools/gen_building_art.py`.

**3. Ngày đêm & lưu game**
- **Ánh sáng** đổi liên tục theo giờ (`world/day_night.gd`, CanvasModulate + dải màu: bình minh hồng → trưa trắng → chiều vàng → hoàng hôn đỏ cam → đêm xanh tím). Mặt trời mọc 0.125, lặn 0.875 (ngày 3 phút, đêm 1 phút).
- **Bóng đổ theo mặt trời** cho cây, đá, bụi, củi, công trình, thổ dân, thú (`world/shadow_layer.gd`): sáng bóng dài về tây, trưa ngắn sau chân, chiều dài về đông, đêm tắt. Vật đứng yên dùng chung một shader chiếu bóng (đổi giờ = đặt một tham số); thổ dân / thú chép từng mảnh của khung cutout sang node bóng. Không Light2D.
- **Ánh lửa ban đêm** ở lửa trại, bếp, lò rèn (sprite cộng sáng, lập loè, trên CanvasLayer riêng không bị làm tối). **Đồng hồ mặt trời** nhỏ cạnh chữ "Ngày N".
- **Lưu / tải** (`world/save_game.gd`, `user://save.json`): seed + ngày giờ + kho chung; trạng thái từng cây / đá / bụi / củi / đá cuội; mọi công trình (cấp, lượt xây dở + vật liệu đã đổ, đồ riêng, đơn rèn); thổ dân (dữ liệu, chỉ số, kỹ năng, **đồ nghề đang giữ**, vị trí, điểm neo, **việc đang nhớ**). **Tự lưu đầu mỗi ngày**; nút Lưu / Tải trên HUD (Tải phải bấm 2 lần trong 3 giây — "Chắc chưa?"). Tải = dựng lại cả cảnh.

**Khác**
- HUD gọn lại: lưu / tải xuống hàng dưới. Bảng debug góc trên-trái tự ẩn sau 8 giây (hiện lại khi bấm F9).
- Lớp UI chính chuyển lên CanvasLayer `layer = 10` (trên ánh lửa).
- Test: 69 test (thêm `test_buildings.gd`, 13 test: luật đặt, thợ xây khuân rồi mới xây + mũ + ăn mừng, chờ vật liệu, huỷ móng trả vật liệu, nâng cấp vẫn chạy cấp cũ, lều 2 chỗ + ngủ đất khi hết chỗ, bếp nấu + ăn ở bếp + cảnh báo thiếu người, sức chứa kho + biển kho đầy, lò rèn rèn rìu rồi người khác lấy dùng, ngày đêm + bóng, lưu/tải đủ thứ, controller đặt móng + chọn công trình). Test cũ: thêm Kho cấp 3 vào bài 3 chặt 2 đập (hang chỉ chứa 30). Soi cảnh báo strict: sạch (test + chạy game). Kiểm tra thêm luồng Lưu → Tải thật (dựng lại cảnh) bằng script tạm: giữ đúng seed, kho, thổ dân.
- Công cụ chụp màn hình thêm `--buildings`, `--ui`, `--times`.

### Quyết định
- **Hang đá là kho tạm, lửa trại chỉ cất món chín** (bạn chốt). Kho chung cộng dồn sức chứa, khuân về chỗ gần nhất (không tách kho từng nơi — đỡ rối cho người chơi casual).
- **Kho đầy thì thôi việc + biển cái kho ✕** (không đứng chờ): người chơi thấy ngay vì sao, và không có ai đứng ôm khúc gỗ mãi.
- **Chỉ huỷ được móng / lượt nâng cấp đang dở**, trả lại hết vật liệu đã khuân tới; công trình xong thì không phá / dời (MVP).
- **Ngủ trong lều = chui vào lều** (ẩn đi, lều bay Zzz, chạm lều để xem ai đang ngủ).
- **Ván mới tay trắng**, Lò rèn cấp 1 rẻ (15 gỗ 10 đá): 2–3 người nhặt củi + đá cuội vài phút là xây được rồi rèn rìu.
- **Vật liệu không trừ lúc đặt móng** — thợ xây khuân từ kho tới, nên luôn đặt được trước rồi kiếm vật liệu sau.
- Lửa trại tối đa 1 người nấu (một nồi); thả người thứ hai thì họ cắm biển.
- Thợ rèn trừ đơn ngay khi bắt đầu một món (hai thợ không rèn trùng); bị ngắt thì trả đơn + vật liệu.
- Bếp / lò rèn đang nâng cấp vẫn nấu / rèn; chạm vào lúc đó là giao việc xây.
- Sân nhảy đi lên được; thả thổ dân vào thì đứng chơi trên sân (chưa có disco).
- Cảnh báo thiếu người đặt **trên mái** chứ không lơ lửng phía trên (công trình đứng sát nhau thì dễ tưởng là của công trình phía sau).
- Tải game dựng lại cả cảnh (reload) thay vì xoá từng thứ — chắc chắn không sót tham chiếu cũ.

### Còn biết
- **Ván mới chưa tự tải ván đã lưu** — mở game là ván mới, bấm nút Tải để chơi tiếp (màn hình bắt đầu ở Đợt 6).
- Thú không được lưu (tải lại thì đàn thú mới); việc đang làm dở (một lượt) cũng không lưu — tải xong thổ dân làm lượt mới của việc đang nhớ.
- Bóng đổ của các vật chồng lên nhau thì đậm hơn một chút (không gộp bóng).
- Ban đêm bong bóng / số bay "+10 gỗ" cũng tối theo (nằm trong thế giới).
- Bóng mờ khi đặt nhà lúc đầu đặt giữa màn hình; trên cảm ứng phải chạm để dời.
- Thổ dân đang ngủ trong lều không chạm được (chạm lều để xem tên).
- Huỷ móng khi thợ đang xây thì thợ cắm biển "búa ✕" (giống "hết việc xây").
- Công trình hư hại (cannibal) để Đợt 5.
- Thanh HUD khá dài: ở màn hình hẹp có thể chạm cạnh trái (chưa có setting "Cỡ giao diện").

### Số nên tinh chỉnh (đề xuất, ở `data/buildings.gd`, `data/tools.gd`, `data/balance.gd`)
- **Hang đá** 30 gỗ / 30 đá / 15 thức ăn. Nếu thấy người mới bị đầy kho quá sớm → 50 / 50 / 20.
- **Chi phí** cấp 1 → 2 → 3: Lều 20g → 40g 15đ → 60g 40đ; Bếp 25g 10đ → 40g 25đ → 60g 50đ; Kho 30g 10đ → 60g 30đ → 120g 60đ; Lò rèn 15g 10đ → 40g 30đ → 70g 60đ; Sân nhảy 20g 10đ → 40g 25đ → 60g 45đ. (Mỗi cây = 30 gỗ, mỗi đá tảng = 16 đá.)
- **Thời gian xây** (1 thợ cấp 1): Lều 20/30/45 giây, Bếp 25/35/50, Kho 30/45/60, Lò rèn 25/40/55, Sân nhảy 20/30/45. Mỗi chuyến khuân 10 gỗ / 5 đá (`BUILD_CARRY`).
- **Rèn:** rìu 4g 2đ, cuốc 3g 4đ, giáo 5g 1đ; 12 giây / món (`FORGE_SECONDS`). Lò chứa mỗi món 2 / 4 / 6.
- **Bếp:** món chín 6 / 10 / 16, thức ăn thô +30 / +60 / +120, nấu 5 giây (`COOK_SECONDS_KITCHEN`).
- **Lều:** 2 / 3 / 4 chỗ, hồi ×1.5 / ×2 / ×2.5.
- **Bóng:** dài nhất 3× (`SHADOW_LENGTH_MAX`), ngắn nhất 0.3×, độ đậm 0.26 (`SHADOW_ALPHA`), ép dẹt 0.45 (`SHADOW_DEPTH_SQUASH`). Ánh sáng: các mốc màu ở `DayNight.LIGHT_KEYS`.

---

## Đợt 2.2 — Gộp tài nguyên, đồ nghề, củi & đá cuội (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **3 tài nguyên chung:** gỗ, đá, thức ăn (icon đùi thịt). Thanh tài nguyên còn 3 ô.
  - Bên trong, thổ dân khuân **món** (`ResourceDefs.ITEMS`): giỏ quả, con cá, nguyên con thú, khúc gỗ (= 10 gỗ), bó củi (1), đá (1), xô đá cuội (1 mỗi viên). Tới kho thì quy ra tài nguyên chung.
  - Kho nhớ thức ăn gồm bao nhiêu quả/cá/thịt (`GameState.add_resource(id, n, item)` / `take_one()`), lúc ăn cầm đúng món trên tay.
- **Đồ riêng của công trình** (`Building.stock`, có sức chứa, bày hình quanh công trình):
  - Món chín cất ở lửa trại (tối đa 4 bát quanh lửa), không còn trên thanh tài nguyên.
  - Đầu bếp lấy thức ăn thô nấu thành món chín; bếp đầy thì đứng chờ.
  - Dân đói ăn món chín trước, hết thì ăn thức ăn thô.
- **Đồ nghề** (`data/tools.gd`: rìu, cuốc, giáo):
  - Chặt cây cần rìu, đập đá tảng cần cuốc, săn cần giáo. Thiếu thì thổ dân cắm biển vẽ món đó gạch chéo, không nhận việc.
  - Có thì tự đi lấy (`TaskFetchTool`) và giữ luôn (`VillagerStatus.tool`). Việc tay không thì đeo đồ nghề sau lưng; việc cần món khác thì về đổi.
  - Chưa có lò rèn: **F10** (bản debug) thêm 1 rìu, 1 cuốc, 1 giáo vào lửa trại.
- **Việc theo `job_id`** (JobDefs): thêm **nhặt củi** và **nhặt đá cuội** (kỹ năng Hái lượm, tay không). Nhặt đủ 3 bó/viên gần nhau rồi mới khuân về.
- **Đồ cầm tay đúng việc:**
  - Hái quả: cầm giỏ, khuân giỏ quả về.
  - Câu cá: cần câu riêng, động tác quăng cần, dây câu + phao vẽ bằng code, khuân cá về.
  - Săn: cầm giáo, hạ thú, vác **nguyên con chổng vó** trên đầu về.
  - Chặt cây: khuân khúc gỗ. Nhặt đá cuội: xách xô.
- **Thiên nhiên** (`NatureSpawner`):
  - Củi rơi dần dưới tán cây (tối đa 20), đá cuội lăn ra quanh đá tảng (tối đa 14).
  - **Vách đá lớn** (3 cái, phía bãi đá, không khai thác được) thỉnh thoảng lăn ra đá tảng — chỉ khi số đá tảng ít hơn lúc đầu.
  - Gốc cây chỉ mọc lại khi số cây ít hơn lúc đầu.
- **Tấm biển:** đứng thì cắm xuống đất trước mặt (tay vịn), ngồi thì hai tay giơ lên, đang đi thì cất. Rảnh mà vừa cắm biển thì đứng yên cạnh biển (`TaskWait`), không đi dạo mất.
- **Spec:** mục 9.2 viết lại, thêm mục 9.4 Lò rèn & đồ nghề (chọn số lượng rèn, rìu/cuốc/giáo trong chiến đấu), xây nhà có khuân vật liệu + mũ công trường (mục 9.3), bảng con số mục 13.
- Hình mới: `icons/res_food`, `props/basket`, `basket_berries`, `bucket`, `bucket_pebbles`, `log`, `twig_bundle`, `fishing_rod`, `env/twigs`, `env/pebbles`, `env/cliff`.
- Test: thêm đồ nghề (thiếu → biển, lấy, giữ khi nhặt đá, đổi món), củi theo mẻ + giới hạn thiên nhiên, biển cắm/giơ. Test runner thêm `-- --only=<tên>`.
- **Đổi tên spec `MVP_PROMPT.md` → `GAME_DESIGN.md`** (giờ là tài liệu thiết kế cả game, không chỉ là prompt dựng MVP). Cập nhật các mục 4, 5, 6, 7, 8, 9, 11, 12 theo Đợt 2.1–2.2; thêm Đợt 2.1, 2.2 vào mục 12; Đợt 3 thêm lò rèn và xây có khuân vật liệu. Các mục cũ hơn trong DEVLOG vẫn ghi tên cũ.

### Quyết định
- **Thức ăn thô ăn được luôn** (no căng): không có đầu bếp vẫn không ai đói cạnh kho đầy. Món chín chỉ thêm vui.
- **Cần câu không cần rèn** (lò rèn chỉ làm rìu, cuốc, giáo theo spec).
- **Mỗi cây 3 khúc gỗ = 30 gỗ** (trước là 9). Chi phí công trình Đợt 3 (10–30 gỗ) sẽ phải tăng hoặc giữ — cần xem lại khi làm Đợt 3.
- Đồ nghề không hỏng.

## Đợt 2.1 — Thổ dân "nói" bằng hình + luật ăn mới (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit.

### Đã làm
- **Tooltip** (theme): nền kem, viền nâu, chữ nâu đậm cỡ 16 thay cho nền xám tối mặc định khó đọc.
- **Bỏ hết chữ trên đầu thổ dân.** Ba kiểu "lời nói" bằng hình:
  - Bong bóng nói (1–2 icon): cảm xúc, lên cấp, tán gẫu (icon ngẫu nhiên: quả, đá, tim, sao, "?"…).
  - Mây nghĩ (`ui/thought_bubble`): đói (đùi thịt, giữ suốt lúc đi tới bếp), buồn ngủ, nghỉ tay (Lười), "lát nữa" (icon việc / "…"), không tới được ("?").
  - Tấm biển (`props/sign`, vẽ trong `VillagerRig`, hai tay giơ lên): đói lả (đùi thịt), hết cây/đá/quả/thú (icon việc ✕), bếp chưa có gì nấu (đùi thịt ✕), đình công (icon việc ✕, giữ tới khi hết đình công).
  - Nhận lệnh: nhún + mặt tươi, không bong bóng.
  - API mới trên `Villager`: `emote` / `chatter` / `think` / `clear_bubble` / `hold_sign` / `lower_sign`; bỏ `say()` và 30 key `BUBBLE_*`.
- **Luật ăn mới:**
  - Đói < 50 → chỉ đi ăn ở bếp (lửa trại), vừa đi vừa nghĩ tới đùi thịt. Bỏ `BushFoodSource`: thổ dân không tự đi hái quả ăn nữa.
  - Bếp hết đồ: người rảnh ngồi bệt nũng nịu (`TaskSulk`, hoạt họa `pout`), thỉnh thoảng nghĩ tới đùi thịt. Người đang làm việc được giao thì làm tiếp, chỉ thỉnh thoảng nghĩ.
  - Đói = 0 thì ai cũng ngồi giơ biển đùi thịt.
  - Vừa mệt vừa đói mà bếp hết đồ thì đi ngủ trước.
  - Ăn một phần ở bếp: no căng 100, +6 giải trí (món chín +10 nữa), +10 thể lực.
  - Ván mới có sẵn 8 quả ở lửa trại.
- Hình mới: `ui/thought_bubble`, `props/sign`, `icons/cross`, `icons/question`, `icons/dots` (ASSET_SPEC + `art_specs`).
- Spec: cập nhật `MVP_PROMPT.md` / `CLAUDE.md` (đầu file, mục 2, 3.1, 5.2, 5.3, 5.5, 6.1, 6.2, 13).
- Test: 53 test (thêm: ngồi dỗi → giơ biển → có đồ thì đi ăn, no căng, thể lực chỉ +10; người đang làm việc không ngồi dỗi; hết quả thì giơ biển). Công cụ chụp màn hình thêm `--hungry`.

### Quyết định
- **Người đang được giao việc không ngồi dỗi khi bếp hết đồ** (chỉ dỗi khi đói lả). Nếu ai cũng bỏ việc để dỗi thì người hái quả cũng ngồi dỗi, làng kẹt luôn.
- **`EAT_ENERGY = 10`:** làm việc nặng thì giữa hai bữa (Đói 100 → 50) mất ~120 giây, cũng là ~50 thể lực. Ăn chỉ bù ~20% nên vẫn phải ngủ.
- **Một quả cũng làm no căng** (đúng "đồ bếp hồi 100%"). Hệ đồ ăn còn chờ chốt (gộp thịt/cá/quả) nên chưa cân lại.

## Đợt 2 — Lao động & tài nguyên (2026-10-02)

**Trạng thái:** xong, chờ chạy thử và duyệt — chưa commit (chủ project tự commit).

### Đã làm
- **Giao việc** chỉ qua `NormalController` → `Commands.assign_job(villager_id, target)`. Chạm (hoặc kéo-thả thổ dân) vào cây → chặt, đá → đập, bụi quả → hái, chỗ câu cá → câu, lợn rừng/hươu → săn, lửa trại → nấu ăn. Chạm mặt đất trống → `Commands.move_villager()`: đi tới đó, đặt điểm neo mới, bỏ việc. Ra lệnh xong thì bỏ chọn.
- **`Job` (việc được ghi nhớ) tách khỏi `Task` (lượt đang làm).** Bộ não bước 6 tạo lượt tiếp theo mỗi khi rảnh: làm → khuân về kho → làm tiếp. Đói/mệt/đình công chỉ thay Task, Job vẫn còn nên xong là tự quay lại. Đang khuân dở mà bị ngắt thì lượt sau khuân nốt (`TaskDeliver`). Thêm mức ưu tiên `WORK` (IDLE < WORK < NEED < SCRIPTED).
- **Hết tài nguyên:** tìm cái tương tự gần nhất trong bán kính (8 ô; hái quả và săn 14 ô), bỏ qua cái người khác đã nhận. Không còn thì thôi việc, đứng chờ tại chỗ (điểm neo = chỗ đang đứng), bong bóng "Hết cây rồi!" / "Hết đá rồi!" / "Hết quả rồi!" / "Hết thú rồi!". Không tới được 3 lần liền → "Không tới được!".
- **Dữ liệu:** `data/jobs.gd` (mỗi việc: mục tiêu, giây, sản lượng, hoạt họa, đồ nghề, bụi, chữ), `data/resources.gd` (gỗ, đá, quả, thịt sống, cá sống, món chín). Lửa trại có thêm cờ `material_storage` và `cook_station` — Đợt 3 chỉ cần gắn cờ cho Kho/Bếp.
- **Tài nguyên trên map:** cây chặt 3 lượt thành gốc, ~3 ngày sau mọc lại; đá đập 4 lượt thì vỡ vụn biến mất (ô đó thành lối đi); vật rung lên mỗi nhát. Chỗ câu cá không cạn.
- **Thú** (`world/animal.gd`): 4 con (lợn rừng, hươu) lang thang trên đồng cỏ, gặm cỏ; thợ săn tới gần thì giật mình đứng im (❗). Bị săn: ngất, sao quay, "bụp" biến mất → 3 thịt; 2 phút sau con mới xuất hiện.
- **Nấu ăn ở lửa trại** (`TaskCook`): lấy 1 thịt/cá sống → 10 giây → 1 món chín. Chưa có gì thì đứng chờ cạnh lửa, thỉnh thoảng nhắc "Chưa có gì để nấu...". Dân đói ăn món chín trước (hồi 60 Đói + vui thêm), rồi tới quả; thịt/cá sống không ăn.
- **Kỹ năng:** làm việc tích kinh nghiệm theo giây (việc thích ×2), đủ 90/180/300/480 thì lên cấp: bong bóng "Lên cấp!", sao bung ra, thông báo nổi. Cấp hiện tại nằm ở `VillagerStatus` (lưu được), `VillagerData.skills` chỉ còn là cấp khởi đầu. Cấp ảnh hưởng tốc độ làm qua `Task.work_speed()`.
- **Đình công** (Giải trí = 0): quăng đồ nghề (đồ văng ra rơi xuống đất), dậm chân, 💢, thông báo "{tên} đình công!". Trong lúc đó 💢 luôn trên đầu, chỉ đứng chơi tại chỗ, giao việc thì nhớ nhưng nói "Không làm!". Giải trí hồi ≥ 40 thì "Làm tiếp thôi!" và quay lại việc.
- **Lười** nghỉ tay giữa chừng (35% mỗi lượt, 4 giây, ngồi, "Nghỉ tí...") rồi tự làm tiếp.
- **Hoạt họa mới:** chặt (giơ rìu ra sau đầu rồi bổ), đập đá (nện búa), câu cá, nấu (khuấy nồi), vung giáo, dậm chân đình công, khuân đồ (hai tay giơ đồ trên đầu, dùng chung với đi/đứng). Đồ nghề cầm tay dùng lại icon kỹ năng, xoay theo cánh tay. Thổ dân ưu tiên đứng bên trái/phải vật khi chặt/đập.
- **Phản hồi:** icon việc trên đầu; đường chấm chấm chạy tới nơi được giao + vòng vàng dưới mục tiêu (cho người đang chọn và 3 giây sau mỗi lệnh); rê chuột lên mục tiêu khi đang chọn người → sáng vòng; kéo-thả có đường kéo; cờ nhỏ ở chỗ bảo đi tới; bong bóng "Ugh!" / "Đi đây!" / "Lát nữa nhé!" (đang ăn/ngủ); bụi khi chặt/đập; số bay "+3 gỗ" ở kho (`fx/fx_layer.gd`).
- **HUD Normal:** thanh tài nguyên góc trên-phải (icon + số theo `Loc.number`, chỉ tính đồ đã vào kho, số nảy khi tăng, tooltip tên), "Ngày N", 4 nút tạm dừng/×1/×2/×3. Phím Space (tạm dừng ↔ chạy lại đúng tốc độ cũ), 1–3. Ra lệnh được cả khi đang tạm dừng.
- **Thông báo nổi** (`ui/common/toast.tscn`) nghe `EventBus.village_event(key, args, icon)` — chỉ mang key, sẵn để làm nhật ký làng Đợt 4.
- **Bảng thông tin:** thêm dòng "Việc được giao: …" (hoặc gợi ý cách giao việc / "Đang đình công"), sao kỹ năng cập nhật ngay khi lên cấp.
- **Đồng hồ ngày** đơn giản trong `GameState` (4 phút một ngày, phát `day_changed`) — ánh sáng ngày đêm vẫn để Đợt 3.
- **Hình mới:** `icons/res_wood`, `res_stone`, `res_meat`, `res_fish`, `res_meal`, `icons/angry`, `animals/boar`, `animals/deer`, `fx/dust`, `ui/speed_pause`, `speed_1..3`, `ui/target_ring`, `ui/move_marker` (ASSET_SPEC.md + `data/art_specs.gd`).
- **Test:** 51 test (thêm `test_jobs.gd`, 11 test). Mô phỏng 5 phút: 3 chặt + 2 đập + 1 người không giao việc — gỗ/đá tăng mỗi phút (lần chạy gần nhất: gỗ 30 → 60 → 72 → 96 → 114, đá 8 → 14 → 18 → 22 → 30), watchdog im lặng, không ai bỏ việc, người rảnh không rời điểm neo. Thêm: ăn xong quay lại việc cũ, hết bụi thì dừng + bong bóng, đình công rồi làm lại, săn → nấu ra món chín, câu cá, controller chạm/kéo giao việc + đặt điểm neo, HUD + tạm dừng, tham số `*_key` được dịch. Soi cảnh báo strict: sạch.
- Công cụ chụp màn hình thêm `--jobs` (giao 2 chặt, 1 đập, 1 hái ngay khi ra khỏi hang, chụp thêm `work.png`).

### Quyết định
- **Ra lệnh xong thì bỏ chọn** — tránh lỡ chạm mặt đất làm người đó bỏ việc. Đường chấm chấm vẫn hiện 3 giây để thấy họ đi đâu.
- **Chạm mặt đất = bỏ việc** và đi tới đó.
- **Đá vỡ hết thì biến mất**, cây thành gốc rồi mọc lại.
- **Mỗi cây/đá/bụi/chỗ câu/con thú chỉ một người làm**; giao nhiều người vào cùng một cây thì người sau tự sang cây gần đó.
- **Đầu bếp không có gì nấu thì đứng chờ** (mỗi lượt chờ 6 giây cho watchdog khỏi tưởng kẹt), không bỏ việc.
- **Cấp kỹ năng chỉ tăng tốc độ**, không tăng sản lượng.
- **Hái quả tìm bụi tương tự trong 14 ô** (không phải 8): bụi trên map cách nhau ~9–13 ô nên 8 ô làm người hái dừng sau đúng một bụi.
- Quả hái về cất ở lửa trại → dân đói lấy ở đó trước (đúng như `StoredFoodSource` đã chuẩn bị).
- Thú và đá vỡ **không bị xoá khỏi cây node** (chỉ ẩn) để Job/Reservations không bao giờ giữ node đã giải phóng. Thú dựng bằng code (`Animal.new()`), không cần `animal.tscn`.
- `Loc.t`: tham số tên kết thúc `_key` là key dịch khác (`{"job_key": "JOB_CHOP"}` → `{job}`) — để thông báo/nhật ký chỉ lưu key. Thêm key `RES_<ID>_NOUN` (viết thường) để ghép vào câu.
- Phím Space/1–3 do `NormalController` xử lý (chạy cả khi tạm dừng); nút bấm ở HUD; cả hai gọi `Commands`.

### Còn biết
- **Đình công khá thường** khi làm việc không thích liên tục: theo spec giải trí 100 → 0 trong 1 ngày làm việc (4 phút), nên một người làm miệt mài sẽ đình công sau chừng 5–6 phút chơi, và đứng chơi hồi lại 40 giải trí mất 1–4 phút (tán gẫu thì nhanh). Xem phần số nên chỉnh.
- **Ngủ hơi thường** lúc mới làm việc: thể lực khởi đầu 60–100 mà làm việc hết sạch trong 1 ngày → vài phút đầu đã có người đi ngủ (đúng spec).
- Thợ săn đứng chéo/dưới con thú lúc vung giáo (thú đứng sững trước khi người tới đúng bên cạnh) — trông vẫn ổn.
- Thợ câu đứng trên bờ, chưa có dây câu/phao vẽ xuống nước.
- Đầu bếp đứng sát lửa trại hơi chồng hình với ngọn lửa.
- Khi 5 người cùng giao đồ ở lửa trại có lúc đứng chồng lên nhau một chút.
- Đồ đang khuân dở mà người chơi bảo đi chỗ khác (chạm mặt đất) thì đồ đó mất.
- Chưa có nút "thôi việc" trong bảng thông tin (chạm mặt đất là cách bỏ việc).
- Bảng debug góc trên-trái vẫn hiện ở bản debug, nằm cạnh HUD.

### Số nên tinh chỉnh (đề xuất)
- `FUN_DECAY_WORK` (100/ngày) → thử 100 / 2 ngày nếu thấy đình công quá thường; hoặc tăng `FUN_RESTORE_IDLE` (0,15/giây) để hết giận nhanh hơn.
- `ENERGY_DECAY_WORK` (100/ngày) → 100 / 1,5 ngày nếu thấy ngủ nhiều quá.
- `SKILL_XP_TO_NEXT` = 90/180/300/480 giây làm việc: lên cấp 2 khá sớm (~1,5 phút, việc thích ~45 giây) cho người chơi thấy ngay; cấp 5 cần ~17 phút làm một việc.
- `COOK_SECONDS_CAMPFIRE` = 10, `HUNT_SECONDS` = 4, `MEAT_PER_HUNT` = 3, `FISH_SECONDS` = 10: một thợ săn nuôi được ~1 đầu bếp; câu cá chậm hơn săn.
- `ANIMAL_COUNT` = 4, `ANIMAL_RESPAWN_SECONDS` = 120.
- `LAZY_BREAK_CHANCE` = 0,35.

---

## Đợt 1.5 — Tái cấu trúc đa chế độ + hành vi "nghe lời" (2026-10-01 → 10-02)

**Trạng thái:** đã duyệt (chuyển sang Đợt 2).

Gồm hai phần: (A) tái cấu trúc theo MVP_PROMPT mục 3.2 (2026-10-01), (B) áp dụng thiết kế mới chốt ngày 2026-10-02 sau khi chơi lại game gốc (thổ dân nghe lời, 4 chỉ số, kỹ năng + việc thích).

### Phần B — Thiết kế mới (2026-10-02)

**Tài liệu:** MVP_PROMPT.md viết lại các mục 2, 3.2, 4, 5.x, 6.x, 7, 8, 9.x, 10, 11, 12, 13, God mode; CLAUDE.md = bản copy y nguyên + phụ lục ghi chú kỹ thuật. Quyết định chốt thêm: ngày đêm chỉ để trang trí (ánh sáng đổi theo giờ, đổ bóng theo mặt trời — Đợt 3), dân số khởi đầu 4 / tối đa 50, hẹn hò tỉ lệ ~10% mỗi lần kiểm tra và có em bé ngay, việc thích chỉ thưởng không phạt.

**Đã làm trong code:**
- **Thổ dân nghe lời** (`villager_autonomy = OBEDIENT`): mỗi người có **điểm neo** (chỗ đứng sau khi ra khỏi hang). Rảnh thì chỉ làm hoạt cảnh trong bán kính `IDLE_RADIUS_CELLS` = 3 ô: dạo vài bước (`TaskStroll`, thay `TaskWander` đi khắp làng), ngồi, gãi, hái hoa dưới chân, tán gẫu với người đứng gần (`IDLE_CHAT_RANGE_CELLS` = 3). Ra xa (sau khi ăn/ngủ) thì tự đi về (`TaskReturn`).
- **Chỉ tự rời chỗ khi:** Đói < 50 → đi ăn; Thể lực < 50% → đi ngủ. Bỏ "ăn vặt khi rảnh"; bỏ bước Lãng mạn mang hoa đi tặng (thành hoạt cảnh hẹn hò ở Đợt 4).
- **Nguồn đồ ăn / chỗ ngủ cắm thêm được:** `FoodSource` (`BushFoodSource` hái quả, `StoredFoodSource` lấy đồ cất ở lửa trại — đang trống tới Đợt 2), `SleepSpot` (ngủ đất cạnh lửa trại ×1). `WorldFinder.find_food_for()` / `find_bed_for()` chọn nguồn; Đợt 3 chỉ cần thêm Bếp/Lều. Lửa trại có cờ `food_storage` trong `data/buildings.gd`.
- **4 chỉ số dạng dữ liệu** (`data/needs.gd`): Máu, Đói, Thể lực, Giải trí — icon, màu, ngưỡng cảnh báo, tốc độ theo hoạt động (rảnh / làm việc / ngủ). `VillagerNeeds.step()` chạy theo `GameModeConfig.enabled_needs` (tắt chỉ số nào thì nó đứng yên và ẩn khỏi bảng). Luật dính nhau: việc nặng đói ×1.5, làm việc thích giải trí giảm ×0.25 (việc khác bình thường), Siêng năng giảm chậm hơn, Đói = 0 thì mất máu.
- **Chạm đáy:** Thể lực = 0 → gục ngủ tại chỗ tới 30% rồi đi tìm chỗ ngủ (`TaskSleep` kiểu `collapsed`). Máu = 0 → ngất 20 giây, sao quay quanh đầu, tỉnh dậy với 20 máu + chút no rồi đi ăn ngay (`TaskKnockedOut`; độ khó Thường có thể chết — Đợt 5).
- **Kỹ năng + việc thích** (`data/skills.gd`): 9 loại việc, cấp khởi đầu 1–2 ngẫu nhiên (+1 theo tính cách, tối đa 3), đúng một việc thích. Thay hoàn toàn `best_job`. `Task.work_speed()` tính theo cấp kỹ năng; hái quả nhanh hơn khi kỹ năng Hái lượm cao. Lên cấp: Đợt 2.
- **`GameModeConfig`** thêm `villager_autonomy` (OBEDIENT / AUTONOMOUS) và `enabled_needs`; `GameState.get_mode()` trả luật mặc định = Normal khi chưa nạp chế độ (test). Bộ não đọc cờ autonomy, nhánh AUTONOMOUS để sẵn chỗ.
- **Hiển thị:** bảng thông tin thay chữ bằng **icon + thanh nhỏ** cho 4 chỉ số (thanh đỏ khi dưới ngưỡng, tên nằm trong tooltip) và **lưới kỹ năng** (icon + sao cấp + tim việc thích). Trên đầu: icon chỉ số thấp nhấp nháy (ẩn khi đang ngủ/ngất), sao quay khi ngất.
- **Khởi đầu 4 thổ dân** (2 nam, 2 nữ). Thể lực khởi đầu 60–100 để không ai vừa ra khỏi hang đã đi ngủ.
- **Hình mới:** `icons/stat_health`, `stat_energy`, `stat_fun`, 9 `icons/skill_*`.
- **Test:** 40 test. Mới: `test_needs.gd` (tốc độ theo hoạt động, việc nặng, việc thích không phạt, tắt chỉ số, đói mất máu, cờ chế độ, gục ngủ và ngất trong thế giới thật). Mô phỏng 5 phút: 4 người, rảnh thì không ai ra xa điểm neo, có tự đi ăn, không còn ăn vặt.

**Quyết định:**
- Điểm neo đặt ở ô thổ dân đi tới sau khi ra khỏi hang (quanh lửa trại); Đợt 2 chạm mặt đất trống → đặt điểm neo mới.
- Icon cảnh báo trên đầu ẩn lúc đang ngủ/ngất (đã có chữ Z / sao) cho đỡ rối.
- Ngưỡng nhấp nháy: Máu < 50, Đói < 50, Thể lực < 50, Giải trí < 20.
- Đình công (giải trí = 0) chưa viết vì chưa có việc để bỏ — Đợt 2.

**Còn biết:**
- Làng "tĩnh" hơn cuối Đợt 1 — đúng thiết kế: chưa giao việc thì dân chỉ quanh quẩn lửa trại.
- Hiếm khi thấy đi ngủ: đứng chơi gần như không mất thể lực. Sẽ thấy rõ khi có việc (Đợt 2).
- Kho ở lửa trại còn trống nên dân đói vẫn đi hái bụi quả (có thể xa vùng dạo chơi) rồi tự quay về.

### Phần A — Tái cấu trúc (2026-10-01)

Chỉ tái cấu trúc theo MVP_PROMPT mục 3.2, không thêm tính năng. Game chạy y như cuối Đợt 1.

### Rà soát (Bước 1) — các chỗ vi phạm đã tìm thấy
- Lõi tự dịch chữ (`Loc.t` trong brain/task, 8 chỗ) và ra lệnh thẳng cho phần hiển thị bong bóng.
- Chưa có API chung `Commands`; `World.spawn_villager` nhận vị trí pixel thay vì ô.
- Chưa có tầng Controller: `SelectionController` nằm trong `world/` và tự nghe InputRouter.
- Chưa có `GameModeConfig`; `main` gắn cứng mọi thứ, không qua cơ chế chọn chế độ.
- `VillagerData` là RefCounted, ngoại hình lưu chỉ số, trộn lẫn trạng thái lúc chơi (nhu cầu), `id` do hàm random cấp.
- UI chưa chia `ui/common/` – `ui/normal/`.

### Đã sửa (Bước 2)
- **`VillagerData` thành `Resource`** — chỉ còn "bản thiết kế": `display_name`, `gender`, `age_stage` (đổi tên từ `stage`), `appearance`, `voice_pitch`, `traits`, `best_job`. Ngoại hình lưu **ID mảnh** (`head_02`, `face_01`, `hair_03`, `body_01`, `accessory_02` hoặc `""`) + **mã màu** `#RRGGBB` cho da/áo/tóc.
- **`VillagerStatus`** (mới) giữ trạng thái lúc chơi: No, Năng lượng, Vui, Máu, Sức đánh, `mood()`. Nhu cầu ban đầu do lõi đặt lúc spawn (RNG gieo theo seed map), không còn do hàm random.
- **`VillagerFactory.create()`** chỉ trả về `VillagerData` (bỏ tham số id).
- **`World.spawn_villager(data, cell, status = null)`** là cách duy nhất tạo thổ dân; lõi cấp `id`, có bảng tra `get_villager(id)`.
- **Autoload `Commands`**: `spawn_villager(data, cell) -> id`, `get_villager(id)`, `set_game_speed(speed)`. Hoạt cảnh chui ra khỏi hang cũng đi qua `Commands.spawn_villager`.
- **Lõi không tự dịch, không ra lệnh cho phần hiển thị**: brain/task gọi `villager.say(key, args, icon)`, `emote(icon)`, `show_heart()`; `Villager` phát signal, `Overhead` nghe rồi mới dịch. Icon việc trên đầu và chữ Z khi ngủ do `Overhead` tự đọc từ thổ dân. Bảng thông tin tự dịch `activity_key/args`.
- **`GameModeConfig`** (`modes/game_mode_config.gd`) với 7 cờ theo spec + `id`, `name_key`, `starts_with_tribe`, `controller_scene`, `hud_scene`. **`modes/normal_mode.tres`** là chế độ Normal.
- **`PlayerController`** (lớp gốc) + **`NormalController`** (`modes/controllers/`) — chuyển nguyên logic chọn/rê/nhấn giữ/huỷ từ `SelectionController` cũ (đã xoá).
- **`main.gd` → `start_game(mode)`**: `GameState.new_game(mode)`, dựng World, gắn controller + HUD theo config, chạy hoạt cảnh mở đầu nếu `starts_with_tribe`. Có `--mode=<đường dẫn .tres>` trên dòng lệnh.
- **UI**: `ui/common/` (bảng thông tin, bảng debug), `ui/normal/hud.tscn` (HUD Normal, đang trống — Đợt 2 thêm tài nguyên/tốc độ).
- Hình mặt đổi tên `face_<kiểu>_<biểu cảm>` (vd `face_01_happy`) để `face` trong ngoại hình là một ID mảnh thật.
- Save/load: chưa có lưu ván chơi (Đợt 3); `VillagerData.to_dict/from_dict` và `VillagerStatus.to_dict/from_dict` đã theo cấu trúc mới, có test đi qua JSON.
- Test: 33 test (thêm `test_modes.gd`: cờ của Normal, khởi động nạp đúng controller + HUD, `Commands.spawn_villager` đúng ô / từ chối ô bị chặn; thêm test ngoại hình là ID mảnh + mã màu, VillagerStatus lưu/đọc). Test mô phỏng 5 phút vẫn qua.
- Tài liệu: CLAUDE.md thêm mục kiến trúc + quy tắc không tự commit; ASSET_SPEC cập nhật tên file mặt.

### Quyết định
- Camera và bảng debug vẫn nghe thẳng InputRouter — kéo/zoom bản đồ giống nhau ở mọi chế độ.
- Task vẫn gọi thẳng `villager.rig.play(...)` (hoạt họa là một phần của thổ dân); tách hết hoạt họa khỏi lõi vượt quá phạm vi "chỉ tái cấu trúc".
- `starts_with_tribe` là cờ thêm ngoài 7 cờ bắt buộc, để chế độ Thần Linh có thể bắt đầu với map trống.

### Còn biết
- Cùng một seed giờ cho ngoại hình bộ lạc **khác** so với Đợt 1 (thứ tự bốc số ngẫu nhiên đổi vì thêm ô `face`). Hành vi không đổi.
- Test `test_modes` cố ý tạo thổ dân trên ô bị chặn nên Output có một dòng WARNING "ô … bị chặn" — đúng như mong đợi.

---

## Đợt 1 — Thổ dân sống động (2026-10-01)

**Trạng thái:** đã duyệt (chuyển sang Đợt 1.5).

### Đã làm
- **Khung cutout** (`villager/villager_rig.gd`): 10 mảnh ghép theo thứ tự spec, chibi ~72 px, ghép ngẫu nhiên 3 đầu × 5 tóc × 3 áo × 4 phụ kiện × 4 màu da × 5 màu áo × 5 màu tóc. Hoạt họa bằng code: đứng thở, chớp mắt ngẫu nhiên, đi, chạy, cúi hái, ăn (nhai), ngủ (nằm + Zzz), nói, gãi mông, ngồi, ngáp, vươn vai, dụi mắt, nhảy cẫng, cầm đồ; lật theo hướng đi; nảy squash & stretch khi dừng chân. Mặt cười/mếu theo tâm trạng.
- **Dữ liệu** (`VillagerData`): tên (bộ tên tiếng Việt), giới, giai đoạn, ngoại hình (chỉ số), cao độ giọng, 1–2 tính cách, việc giỏi nhất, No/Năng lượng/Vui/Máu. Lưu/đọc JSON được.
- **8 tính cách** ở `data/traits.gd` dạng hệ số (Lười làm chậm 20% và hay ngồi, Háu ăn mau đói nhưng ăn vui gấp đôi, Lãng mạn hay hái hoa tặng người khác…).
- **Bộ não** suy nghĩ mỗi 0.3–0.6 s, lệch nhịp nhau: đói (<20) → bỏ việc rảnh đi hái quả ăn, kèm bong bóng "Đói quá!"; kiệt sức (<15) → ra quanh lửa trại nằm ngủ, bong bóng "Buồn ngủ..."; rảnh → chọn ngẫu nhiên có trọng số: đi dạo, tán gẫu theo cặp ("Ugga bugga!", "Bi bô?"…), hái hoa (Lãng mạn mang đi tặng, bật tim), gãi mông, ngồi phơi nắng (mệt thì ngáp), ăn vặt.
- **Đặt chỗ**: mỗi bụi quả, mỗi chỗ ngủ chỉ một người nhận. Bụi hái xong mọc lại sau 1 ngày.
- **Mở đầu**: 6 người (3 nam, 3 nữ) lần lượt ló ra khỏi hang, dụi mắt, ngáp, đi ra lửa trại. Cùng seed → cùng bộ lạc.
- **Chọn thổ dân**: chạm/click → vòng vàng dưới chân + tên trên đầu + bảng thông tin (chân dung là rig thật đang thở, tên, giới tính, tính cách kèm giải thích, 3 thanh nhu cầu, mặt tâm trạng, việc đang làm, việc giỏi nhất ⭐, nút ✕). Rê chuột / nhấn giữ → hiện tên. Chạm chỗ trống, Esc, chuột phải → bỏ chọn.
- **Watchdog** (chỉ bản debug): cảnh báo trong Output nếu một việc kéo quá 40 giây (trừ ngủ) hoặc đang đi mà đứng im 4 giây.
- Test mới (30 test tổng): tạo thổ dân hợp lệ, lưu/đọc, hệ số tính cách, **mô phỏng 5 phút game** (×20): cả 6 người ra khỏi hang, không ai chết đói khi còn quả, không ai lọt vào ô bị chặn, watchdog im lặng, thấy ≥5 loại hoạt động (gồm tán gẫu), chọn đúng người khi chạm, bảng hiện/ẩn đúng. Lần chạy gần nhất thấy đủ 8 loại: ra khỏi hang, đi dạo, tán gẫu, hái hoa, gãi, ngồi, ăn vặt, ngủ.
- Công cụ chụp màn hình thêm tuỳ chọn `--wait=` (chờ N giây game), `--speed=` (tua nhanh lúc chờ), `--select` (mở sẵn bảng thông tin người đầu tiên).

### Lỗi đã sửa trong lúc làm
- Sắp xếp chỗ ngủ gọi `randf()` ngay trong hàm so sánh → Godot báo "bad comparison function". Sửa: bốc số ngẫu nhiên cho từng ô trước rồi mới sắp xếp.
- Nút ✕ trên bảng thông tin chỉ hiện thành một chấm nhỏ (Button không giãn icon) → đổi sang `TextureButton`.
- Biến dùng chung `_step`, `_timer` ở lớp `Task` bị Godot cảnh báo "không dùng" (vì chỉ lớp con dùng) → đổi tên thành `step`, `timer`.

### Quyết định
- Rig dựng bằng code (không vẽ trong scene) để vị trí khớp nằm một chỗ (hằng số đầu file) và dùng lại được cho chân dung.
- Mảnh da/áo/tóc vẽ trắng rồi nhân màu (`modulate`) → chỉ cần một hình cho mọi màu da.
- Việc mỗi loại một file `villager/tasks/task_*.gd`, đều có `stop()` luôn được gọi để trả chỗ đã đặt → không bao giờ kẹt bụi quả.
- Các câu hỏi "tìm chỗ" tách ra `WorldFinder` để `World` không thành god object.
- Tán gẫu dùng chung một `ChatSession` cho hai người: một bên bỏ đi thì bên kia cũng thôi.
- Đợt 1 chưa có chết: No về 0 thì máu giảm nhưng giữ 1 (ngất/mất người làm ở Đợt 5 theo độ khó).
- Thổ dân ăn vặt từ khi No < 60 nếu rảnh, nên hiếm khi tụt xuống mức "Đói quá!" khi còn quả.

### Còn biết / để sau
- Chưa có âm thanh lẩm bẩm (để Đợt 6).
- Lâu lâu hai người đứng gần chồng lên nhau một chút khi cùng đứng cạnh một bụi/người.
- Hái hoa không làm mất bông hoa trên map.
- Mắt ở tư thế nằm ngủ vẫn là mặt nghiêng — ổn với hình tạm.
- Bảng debug (góc trên) và bảng thông tin (góc dưới) cùng nằm bên trái, hơi chật.

### Số nên tinh chỉnh (đề xuất)
- `HUNGER_SNACK` = 60 → hạ còn ~40 nếu muốn thấy dân đói rõ hơn.
- `ENERGY_DECAY_IDLE`: hiện ~2,5 ngày mới cần ngủ; Đợt 3 có ngày/đêm thì cho ngủ theo đêm.
- `FUN_CHAT` = 3, `FUN_SIT` = 1,5: Vui lên khá nhanh, hầu như ai cũng vui — có thể giảm để tâm trạng dao động hơn.
- `IDLE_WEIGHTS` trong `villager/villager_brain.gd`: trọng số chọn hoạt cảnh rảnh.

---

## Đợt 0b — Map sinh động hơn (2026-10-01, theo góp ý sau Đợt 0)

**Trạng thái:** đã duyệt, commit `13d045a` (gộp chung với Đợt 0).

### Đã làm
- **Gió chung** (`world/wind.gd`): một đồng hồ gió + sức gió lên xuống theo đợt. Shader `fx/wind_sway.gdshader` làm cỏ, hoa, bụi, cây, ngọn lửa nghiêng theo cùng một nhịp; sóng gió lướt từ trái sang phải.
- **Mặt hồ**: shader `fx/water_shimmer.gdshader` vẽ đường gợn sáng lượn sóng trôi theo gió (chỉ tác động lên điểm ảnh xanh nước). `WaterLife` thêm gợn sóng nhỏ hiện lên rồi trôi đi (gió mạnh thì nhiều hơn), và 2–6 con cá bơi lượn.
- **Chỗ câu cá**: vòng gợn lan ra đều đều, thỉnh thoảng một con cá nhảy lên theo cung.
- **Lửa trại**: 4 khung hình chạy 8 hình/giây + phập phồng nhẹ, ngọn lửa nghiêng theo gió, tàn lửa bay lên và bị gió đẩy dạt.
- Test mới: gió chạy, cá không bao giờ bơi lên bờ, lửa đổi khung hình, có gợn sóng.

### Quyết định
- Mỗi loại vật dùng **chung một ShaderMaterial**, node Wind cập nhật vài material mỗi frame — rẻ dù có hàng trăm sprite.
- Đồng hồ gió chạy theo thời gian game (không dùng `TIME` của shader) để tạm dừng thì mọi thứ đứng yên, ×3 thì nhanh theo.
- Cá chỉ bơi theo đường thẳng mà mọi điểm trên đường đều là ô nước, đích chọn ở ô có 4 phía là nước → không lấn lên bờ.
- Bỏ gợn sóng vẽ cứng trong ô nước (lặp thành lưới), thay bằng gợn sóng động.
- Số tinh chỉnh hiệu ứng nằm ở đầu từng script (`wind.gd`, `water_life.gd`, `fish.gd`, `fish_spot_fx.gd`, `campfire_embers.gd`) vì là số hình ảnh, không phải cân bằng game.

---

## Đợt 0 — Dựng khung (2026-10-01)

**Trạng thái:** đã duyệt, commit `13d045a`.

### Đã làm

- **Project**: tên `Tribe Vibes`, renderer Compatibility (desktop + mobile), 1280×720, `canvas_items` + `expand`, main scene `main.tscn`, input map (WASD/mũi tên, Space, 1–3, Esc, F9), theme mặc định, bus âm thanh Master/Music/SFX/Voice, màu nền xanh cỏ đậm (nếu lỡ thấy mép map).
- **Autoload** (thứ tự nạp): `EventBus` → `SaveSystem` → `GameState` → `Loc` → `ArtLibrary` → `InputRouter`.
- **Đa ngôn ngữ** (`Loc`): `t`, `plural`, `number`, `set_language`, `available_languages`, `language_display_name`, signal `language_changed`. Ngôn ngữ lưu ở `user://settings.cfg`. F9 (chỉ bản debug) đổi vòng vi ↔ en; nhãn cập nhật ngay.
- **Font** Nunito (OFL, kèm `assets/fonts/OFL.txt`), dùng bản variable với độ đậm 650 cho chữ thường, 900 cho tiêu đề.
- **Bản đồ** 48×36 ô sinh theo seed: hang + lửa trại giữa map, rừng một phía (trái/phải), bãi đá phía đối diện, hồ phía trên hoặc dưới (hình hạt đậu, bờ bo tròn), đồng cỏ nhiều hoa phía còn lại (cũng là hướng cannibal sẽ đến), bụi quả quanh làng và ngoài đồng cỏ, 4 chỗ câu cá gần làng nhất. Mọi vật thể đều đi tới được từ cửa hang.
- **Camera**: kéo (chuột trái ở chỗ trống / chuột giữa / một ngón / WASD / touchpad hai ngón), zoom về phía con trỏ (lăn chuột / chụm hai ngón / chụm touchpad), mượt, không bao giờ lộ ra ngoài map, vẫn chạy khi tạm dừng.
- **Hình tạm SVG** (2×, viền nâu, màu ấm): 3 ô cỏ, 2 mảng cỏ, 2 bãi đất, 15 ô nước, 2 loại cây, gốc cây, 2 cỡ đá, bụi có/hết quả, 3 hoa, 2 khóm cỏ, chỗ câu cá, hang, lửa trại + ngọn lửa phập phồng.
- **Test headless** (25 test): i18n (fallback, tham số, số nhiều, định dạng số, CSV sạch), sinh map trên 12 seed (lặp lại được, đủ tài nguyên, đúng bố cục, không chồng nhau, tới được hết), InputRouter (click, kéo, lăn, chuột phải, chuột giả lập, chạm, chụm, nhấn giữ, kéo-giao-việc), dựng World thật.
- **Công cụ**: `tools/gen_water_tiles.gd` (sinh hình nước), `tools/screenshot.tscn` (chụp màn hình), `tools/strict_warnings.cfg` (soi cảnh báo GDScript).
- **Tài liệu**: `ASSET_SPEC.md`, `i18n/README.md`, `CLAUDE.md`, `PLAN.md`, file này.

### Quyết định & lý do

- **Art vẽ 2×, hiển thị ×0.5** — nét khi zoom ×2 và trên điện thoại. TileMapLayer dùng ô 128 px với node scale 0.5; mọi toạ độ ô đi qua `WorldGrid` (64 px) để không ai phải tính scale.
- **Nước kiểu dual-grid** (lớp nước lệch nửa ô): 15 hình là đủ cho mọi hình dạng bờ, góc bo là 1/4 hình tròn nên ô nước lẻ thành vũng tròn và bờ bậc thang thành đường cong. Hình sinh bằng code để dễ đổi màu.
- **Cây/đá/bụi là node**, không phải tile — vì cần y-sort với thổ dân, đặt chỗ, tương tác, đổi hình khi hết.
- **Hang và lửa trại là `Building`** dựng từ `data/buildings.gd` ngay từ giờ, để Đợt 3 chỉ cần thêm trạng thái móng/hư hại, không phải viết lại.
- **Mật độ rừng tối đa 0.42**: cao hơn ~0.4 thì rừng thành bức tường, cây bên trong không tới được và bị bỏ → rừng rỗng ruột.
- **Fallback tiếng Việt**: CSV import không nén (`compress=0`); `Loc` chép chữ vi vào mọi ô trống của ngôn ngữ khác lúc khởi động → cả `Loc.t` lẫn chế độ tự dịch của Control đều không hiện chữ rỗng. Mỗi lần chạy in một dòng `[Loc] 'en' thiếu …` để biết còn bao nhiêu câu chưa dịch.
- **Tự nạp mọi `.translation` trong `i18n/`**: thêm cột vào CSV là có ngôn ngữ mới, không cần sửa Project Settings (đã thử với cột `ja` tạm rồi xoá).
- **Ghi chú trong CSV**: dòng bắt đầu bằng `#` (đủ dấu phẩy) được Godot bỏ qua — có test canh.
- **Input**: bắt đầu cử chỉ ở `_unhandled_input` (UI được ưu tiên), theo dõi/kết thúc ở `_input` (kéo lướt qua UI không đứt); bỏ chuột giả lập từ cảm ứng để không nhận đôi. Nhấn giữ 0.4 s đo bằng thời gian thật.
- **Tốc độ game** dùng `Engine.time_scale` + `SceneTree.paused`; camera và InputRouter `PROCESS_MODE_ALWAYS`, camera dùng thời gian thật.
- **Seed**: `--seed=N` trên dòng lệnh > `Balance.DEBUG_FIXED_SEED` > ngẫu nhiên.
- **Ô cỏ trơn chiếm ~45%** + mảng cỏ sáng/tối lớn rải ngẫu nhiên: lúc đầu hoa văn cỏ lặp thành lưới khi zoom gần, nhìn rất "ô vuông".
- Đổi tên enum hướng trong `MapData` thành `Edge` vì Godot có sẵn enum toàn cục `Side` (gây lỗi parse khó hiểu).

### Còn biết / để sau

- Bảng debug góc trên-trái che một phần map (chỉ có ở bản debug, sẽ thay bằng HUD thật ở Đợt 2).
- `SaveSystem` mới có phần setting và hàm đọc/ghi JSON; lưu ván chơi làm ở Đợt 3.
- Bản Web chưa xuất (Đợt 6). Chưa có âm thanh.
- Bãi đá hơi nhiều đá nhỏ lấm tấm; xem lại khi có thổ dân đi đập đá.

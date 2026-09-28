# Lexa — Từ vựng IELTS theo chủ đề & band

Ứng dụng iOS thuần SwiftUI học từ vựng IELTS: mỗi ngày một từ mới theo band và chủ đề bạn chọn, widget ngoài màn hình khóa, thư viện lưu trữ toàn bộ từ đã xuất hiện và thống kê theo tuần / tháng / quý / năm.

## Tính năng

- **Từ của ngày** — 1 từ chính + 4 từ gợi ý, chọn deterministically theo ngày từ kho 642 từ lõi IELTS lọc theo band + chủ đề của bạn. Widget và app luôn ra cùng một từ mà không cần đồng bộ.
- **Band & chủ đề** — 4 dải band (5.0–5.5 / 6.0–6.5 / 7.0–7.5 / 8.0–9.0, xếp theo tần suất BNC) và 16 chủ đề (Giáo dục, Kinh tế, Môi trường, Pháp lý…).
- **Ngôn ngữ nghĩa** — chọn nghĩa hiển thị: Tiếng Việt hoặc định nghĩa tiếng Anh (song song cả hai trên thẻ từ). Cài đặt nằm trong **Cài đặt → Ngôn ngữ nghĩa**; widget theo cùng cài đặt.
- **Widget màn hình khóa** — 4 kiểu: `accessoryRectangular`, `accessoryInline`, `accessoryCircular` (khóa màn hình) và `systemSmall` (màn hình chính). Tự đổi từ mỗi ngày, có nút lưu tương tác ngay trên widget (iOS 17).
- **Thư viện** — mọi từ đã xuất hiện kèm ngày đầu tiên, số lần xuất hiện, đánh dấu đã lưu; tìm kiếm theo từ hoặc nghĩa; lọc theo band / chủ đề / đã lưu.
- **Thống kê** — từ mới theo tuần (7 ngày), tháng (30 ngày), quý (13 tuần), năm (12 tháng) với biểu đồ Swift Charts, tổng cộng và số từ đã lưu.
- Giao diện Việt / Anh, dark mode, haptic, hasla serif kiểu từ điển (New York).

## Build không cần Mac (Windows + GitHub Actions)

Repo có sẵn `.github/workflows/build.yml` — GitHub build app trên máy ảo macOS miễn phí và trả về file IPA chưa ký.

1. Tạo repo mới trên [github.com](https://github.com/new) (để **Public** — runner macOS free không giới hạn phút), rồi push project:
   ```bash
   cd lexa
   git init
   git add .
   git commit -m "Lexa — IELTS vocabulary"
   git remote add origin https://github.com/<user>/<repo>.git
   git push -u origin main
   ```
2. Chờ ~10–20 phút, vào tab **Actions → Build iOS IPA → run mới nhất → Artifacts** tải `Lexa-unsigned-ipa` về máy.
3. Tải [Sideloadly](https://sideloadly.io) trên Windows, cài thêm **Apple Devices** (Microsoft Store) để có driver USB.
4. Cắm iPhone vào PC, mở Sideloadly → kéo file `Lexa-unsigned.ipa` vào → nhập **Apple ID** của bạn → Start. Nhập mật khẩu Apple ID khi được hỏi (chỉ dùng để ký, lưu trên máy bạn).
5. Trên iPhone: **Cài đặt → Cài đặt chung → Quản lý VPN & Thiết bị** → tin cậy hồ sơ Apple ID của bạn → mở app.

Giới hạn của Apple ID cá nhân (miễn phí): app phải **ký lại mỗi 7 ngày** (chạy lại Sideloadly với cùng file IPA, giữ nguyên dữ liệu), tối đa 3 app. Widget, App Group, thống kê đều hoạt động đầy đủ.

Có tài khoản **Apple Developer trả phí (99 USD/năm)** thì ký phát hành trong CI và cài không bị hạn chế 7 ngày (hoặc lên TestFlight) — mở issue/đổi workflow khi cần.

## Build (truyền thống)

Yêu cầu: **Xcode 15+** (iOS 17 SDK) trên macOS và [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
cd lexa
xcodegen            # tạo Lexa.xcodeproj từ project.yml
open Lexa.xcodeproj
```

Trong Xcode:

1. Chọn target **Lexa** → tab *Signing & Capabilities* → chọn **Team** của bạn. Làm tương tự với target **LexaWidget**.
2. Tạo **App Group** `group.com.lexa.vocab` trên [developer.apple.com](https://developer.apple.com/account/resources/identifiers/list/applicationGroup) (Identifiers → App Groups) và bật cho cả hai App ID (`com.lexa.vocab`, `com.lexa.vocab.widget`). Entitlements đã khai báo sẵn trong project — nếu đổi bundle ID, đổi luôn group trong `project.yml` và `Shared/AppGroup.swift`.
3. Build & chạy target **Lexa**.

### Thêm widget màn hình khóa

Nhấn giữ nền màn hình khóa → **Tùy chỉnh** → chọn màn hình khóa → mục **Thêm widget** → chọn **Lexa**. Widget tự cập nhật theo ngày (timeline 7 ngày, reload tiếp sau đó).

### Deep link

Widget và mọi đường dẫn `lexa://today` mở thẳng tab **Hôm nay**.

## Dữ liệu

- `Resources/vocab.json` — 642 từ lõi IELTS, mỗi từ gồm: từ, IPA, từ loại, band (5/6/7/8 theo tần suất BNC), chủ đề, định nghĩa tiếng Anh, câu ví dụ và nghĩa tiếng Việt.
- Nguồn: [skywind3000/ecdict](https://github.com/skywind3000/ecdict) (IPA + định nghĩa WordNet + tag IELTS + tần suất BNC, giấy phép MIT). Nghĩa tiếng Việt, câu ví dụ và tuyển chọn từ được soạn thủ công.
- Pipeline nằm trong `tools/`:
  - `ecdict.csv` (tải từ repo ECDICT) → `extract` → `candidates.tsv`
  - `curated_1..3.tsv` — bảng soạn tay: `word | topic | nghĩa tiếng Việt | ví dụ`
  - `python tools/build_vocab.py` — ghép, validate (cột, trùng lặp, phủ band×chủ đề) và ghi `Resources/vocab.json`.

### Mở rộng kho từ

`candidates.tsv` còn ~500 ứng viên đã lọc sẵn (có IPA, định nghĩa, tần suất). Thêm dòng mới vào `curated_*.tsv` theo đúng 4 cột rồi chạy lại `build_vocab.py`. Muốn thêm ngôn ngữ nghĩa mới (ví dụ中文), thêm khóa trong JSON của từng từ và một bảng trong `L10n.tables` + một lựa chọn trong `SettingsView`.

## Cấu trúc

```
lexa/
├─ project.yml          # XcodeGen: 2 target (app + widget), App Group, URL scheme
├─ App/                 # SwiftUI app: Today, Khám phá, Thư viện, Thống kê, Cài đặt
├─ Shared/              # Model, VocabRepository, ProgressStore, DailyWord, L10n, DesignSystem
├─ Widget/              # WidgetKit: timeline 7 ngày + AppIntent lưu từ
├─ Resources/           # vocab.json + Assets.xcassets (icon, accent color)
└─ tools/               # pipeline dữ liệu (Python)
```

## Ghi chú kỹ thuật

- Lưu trữ tiến trình: JSON trong App Group container (`progress.json`) — app và widget đọc/ghi chung, không cần iCloud.
- Chọn từ trong ngày: `dayIndex * 5 + slot` rọi vào danh sách từ đã sắp bằng FNV-1a hash của ID — đổi band/chủ đề là đổi từ ngay, mọi thiết bị ra cùng kết quả.
- Widget xin `policy: .after(nextMidnight+8)` nên không tốn pin; không cần server, hoạt động offline hoàn toàn.
- iOS 17 trở lên (khóa màn hình widget + `@Observable` + nút tương tác trên widget).

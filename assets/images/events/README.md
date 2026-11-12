# EventHub event banners

These eight landscape illustrations are fictional, locally bundled demo assets. Each was generated specifically for EventHub with OpenAI ImageGen on 2026-11-11. No third-party stock photography, remote image URL, brand, or existing event poster is used.

| Asset | Sample event |
|---|---|
| `saigon-tech-meetup.png` | Saigon Tech Meetup: AI trong đời sống |
| `indie-music-night.png` | Đêm nhạc indie bên hiên |
| `design-thinking-workshop.png` | Xưởng tư duy thiết kế thực hành |
| `green-community-run.png` | Chạy xanh Sài Gòn |
| `startup-pitch-day.png` | Ngày hội ý tưởng khởi nghiệp Đà Nẵng |
| `handmade-market.png` | Chợ phiên thủ công sáng tạo |
| `vietnamese-food-festival.png` | Ngày hội món ngon ba miền |
| `danang-photography-walk.png` | Dạo phố Đà Nẵng qua ống kính |

The images are illustrative artwork for the fictional sample events, not documentary photographs of real event listings. They are referenced through `Event.bannerAssetPath` and bundled by `pubspec.yaml`, so the app can display them offline. If a path is absent or fails to load, `EventBanner` and `AppEventCard` provide local fallback artwork.

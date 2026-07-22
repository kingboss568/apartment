# 公寓大廈管理條例全圖解 Release Status

Updated: 2026-07-22 Asia/Taipei

- ASC app: `6776649824`
- Bundle ID: `com.taiwanarch.condolaw`
- Live baseline: `1.1 (5)` / build `VALID`
- Update target: `1.2 (2)`
- Account/team: `jushiung@gmail.com` / Yu Shiung Jiang (`7H7ZUG2WX8`)

## Ready locally

- 250/250 article records and HEIC assets matched.
- `圖卡快覽` two-column gallery and six-tab navigation implemented.
- 10 groups / 100 unique interactive tools implemented.
- Xcode 27 beta Simulator build passed.
- iPhone 6.9 UI navigation/tool interaction test passed.
- iPhone 6.9 and iPad 13 visual screenshot QA passed.
- Fastlane metadata uploaded to ASC version 1.2; local binary upload disabled.
- Fastlane uploaded all 12 current screenshots to ASC version 1.2.

## Release gates

- [x] Push current source/privacy manifest to GitHub.
- [x] Verified the existing single Xcode Cloud `Archive - iOS` workflow (run `030ffeb3-dc8b-4bc6-8b69-c372ec824c11`).
- [x] Cloud build `2` succeeded; ASC build `5772a57a-2e08-424a-8226-a7b73c3bbd50` is `VALID` for version 1.2.
- [x] Capture and validate current 6 iPhone 6.9 + 6 iPad 13 screenshots.
- [x] Upload the 12 current screenshots to ASC.
- [x] Fastlane selected Cloud build `2`; version 1.2 and submission `c0e9ce97-1020-4127-8e8c-2646452e08ac` are `WAITING_FOR_REVIEW`.

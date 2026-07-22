# 公寓大廈管理條例全圖解 Release Status

Updated: 2026-07-22 Asia/Taipei

- ASC app: `6776649824`
- Bundle ID: `com.taiwanarch.condolaw`
- Live baseline: `1.1 (5)` / build `VALID`
- Update target: `1.2 (6)`
- Account/team: `jushiung@gmail.com` / Yu Shiung Jiang (`7H7ZUG2WX8`)

## Ready locally

- 250/250 article records and HEIC assets matched.
- `圖卡快覽` two-column gallery and six-tab navigation implemented.
- 10 groups / 100 unique interactive tools implemented.
- Xcode 27 beta Simulator build passed.
- iPhone 6.9 UI navigation/tool interaction test passed.
- iPhone 6.9 and iPad 13 visual screenshot QA passed.
- Fastlane metadata uploaded to ASC version 1.2; local binary upload disabled.

## Release gates

- [x] Push current source/privacy manifest to GitHub.
- [ ] Create the Xcode Cloud product relationship and single `Archive - iOS` workflow.
- [ ] Cloud build `6` succeeds and appears in ASC as `VALID`.
- [x] Capture and validate current 6 iPhone 6.9 + 6 iPad 13 screenshots.
- [ ] Upload the 12 current screenshots to ASC.
- [ ] Fastlane selects Cloud build `6`, submits update, and ASC shows `WAITING_FOR_REVIEW`.

# 公寓大廈管理條例全圖解 iOS

- Bundle ID: `com.taiwanarch.condolaw`
- App Store Connect ID: `6776649824`
- Update target: `1.2 (6)`
- Apple team/account: Yu Shiung Jiang / `jushiung@gmail.com`

## Commercial update

- Six functional tabs, including `圖卡快覽`.
- Pinterest-style two-column gallery backed by all 250 local illustrations.
- 100 unique interactive professional tools with checklist, progress, risk score, persistent notes, and sharing.
- UI tests live in `UITests/CommercialUpdateUITests.swift`.

## Release contract

The App Store binary must be produced only by an Xcode Cloud `Archive - iOS` workflow and synchronized to App Store Connect as `VALID`. Fastlane may update metadata/screenshots, select that Cloud build, and submit review. Local IPA/archive upload is disabled in `fastlane/Fastfile`.

Use the Jiang account and Xcode 27 beta through a per-command `DEVELOPER_DIR`; never switch global `xcode-select`.

# 公寓大廈管理條例全圖解 iOS

- Bundle ID: `com.taiwanarch.condolaw`
- App Store Connect ID: `6776649824`
- Update target: `1.2 (2)`
- Apple team/account: Yu Shiung Jiang / `jushiung@gmail.com`

## Commercial update

- Six functional tabs, including `圖卡快覽`.
- Pinterest-style two-column gallery backed by all 250 local illustrations.
- 100 unique interactive professional tools with checklist, progress, risk score, persistent notes, and sharing.
- UI tests live in `UITests/CommercialUpdateUITests.swift`.

## Release contract

The App Store binary must be produced only by an Xcode Cloud `Archive - iOS` workflow and synchronized to App Store Connect as `VALID`. Fastlane may update metadata/screenshots, select that Cloud build, and submit review. Local IPA/archive upload is disabled in `fastlane/Fastfile`.

Use the Jiang account and Xcode 27 beta through a per-command `DEVELOPER_DIR`; never switch global `xcode-select`.

## App Store Connect result

- Xcode Cloud Archive run: `030ffeb3-dc8b-4bc6-8b69-c372ec824c11`
- Selected ASC build: `1.2 (2)` / `5772a57a-2e08-424a-8226-a7b73c3bbd50` / `VALID`
- Review submission: `c0e9ce97-1020-4127-8e8c-2646452e08ac` / `WAITING_FOR_REVIEW`
- Storefront assets: 6 iPhone 6.9 + 6 iPad 13 screenshots, all `COMPLETE`; IAP `6776651573` is `APPROVED`.

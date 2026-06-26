# Corporate Card Companion

Flutter demo for a fictional corporate card receipt workflow. The app helps a card user find transactions missing receipts, attach an image, and keep browsing while a mock upload runs.

## Current Scope

- Japanese UI for transaction list, detail, receipt selection, mock upload, and demo settings.
- Fixture-backed data only. No real card data, payment, backend, OCR, AI API, or OS-level background upload.
- Upload state is kept in an app-level Riverpod controller, so the list can show upload progress after leaving the detail page.
- `brandId` is passed through repository and upload calls. Phase 8 will add the visible brand switch UI.

## Run

```powershell
flutter pub get
flutter run -d chrome
```

Useful checks:

```powershell
dart format .
flutter analyze
flutter test
```

Verified environment during Phase 7:

- Flutter 3.41.2 stable
- Dart 3.11.0
- Android toolchain available
- Chrome available
- Windows desktop build has a Visual Studio installation warning

## Architecture

The app uses a lightweight feature-first layout:

- `lib/app`: app shell and router
- `lib/core`: formatting and debug analytics
- `lib/features/transactions`: transaction domain, fixture repository, list/detail UI
- `lib/features/receipt_upload`: image picking, upload job model, fake upload repository, queue controller
- `lib/features/settings`: demo-only controls and recent analytics events

Riverpod is used for dependency injection and state. The app does not add Clean Architecture use-case classes because the current flows are still small enough for controllers to orchestrate directly.

## Analytics and KPI

Phase 7 adds in-memory Debug Analytics. Recent events are visible in `デモ設定`.

Tracked event names:

- `app_opened`
- `transaction_list_viewed`
- `transaction_filter_changed`
- `transaction_detail_opened`
- `receipt_attach_tapped`
- `receipt_image_selected`
- `receipt_upload_started`
- `receipt_upload_succeeded`
- `receipt_upload_failed`
- `receipt_upload_retried`
- `brand_switched` is reserved for Phase 8

Allowed properties only:

- `brandId`
- `transactionStatus`
- `receiptStatus`
- `durationMs`
- `retryCount`
- `errorType`

Never recorded:

- Merchant name
- Memo text
- Image path or image content
- Raw transaction ID
- Card last four
- Amount

KPI definitions:

- Time to Receipt Upload: app open to first `receipt_upload_succeeded`.
- Upload Success Rate: `receipt_upload_succeeded / receipt_upload_started`.
- Retry Rate: `receipt_upload_retried / receipt_upload_started`.
- Missing Receipt Completion Rate: users who choose the missing-receipt filter and later reach upload success.
- Time on Task: `transaction_detail_opened` to `receipt_upload_started`.

Product hypotheses:

- Putting the missing-receipt summary on the list should shorten time to the target transaction.
- Nonblocking upload should reduce abandonment after starting upload.
- A local retry action should improve completion after a network-like failure.

## Tests

Current tests cover:

- Money and DTO mapping
- Transaction filtering
- Brand data isolation in fixture repository
- Loading, error, retry, filtering, detail, image selection, upload, and retry widget flows
- Duplicate active upload prevention
- Retry preserving the same idempotency key
- Analytics property whitelisting

## Known Limits

- Debug Analytics is in memory and resets on restart.
- Upload is app-process async work only, not OS background transfer.
- Brand switching UI is not implemented until Phase 8.
- README is still intentionally short; Phase 10 will turn it into the final presentation document.

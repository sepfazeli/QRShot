QRShot Source Files
===================

1. Create a new "iOS App (SwiftUI)" project in Xcode 16 named **QRShot**.
   • Team: your developer account
   • Bundle ID: com.sepehrfazeli.qrshot  (or your chosen reverse‑DNS)

2. Delete the two template files Xcode generates:
   • ContentView.swift
   • QRShotApp.swift  (or <ProjectName>App.swift)

3. Drag **all six Swift / xcprivacy files** from this folder into the Xcode
   Project Navigator *at the root level*. Ensure "Copy items if needed"
   and "Add to targets: QRShot" are ticked.

4. Link SwiftData if Xcode did not auto‑embed it:
   target ▸ General ▸ Frameworks, Libraries & Embedded Content ▸ “+”
   ➜  SwiftData.framework  (Embed & Sign)

5. Build & Run on a device (⌘R) — type text, Generate QR, share.

6. Add an App Icon (1024 × 1024) and screenshots, then follow the archive/
   upload checklist previously provided to submit to App Store Connect.

Happy shipping!  — 2025-04-18

📸 QRShot

QRShot is a sleek, SwiftUI-powered iOS app that lets you generate, decode, and manage QR codes from text or images. Customize foreground/background colors, preview your QR codes, and maintain a searchable history — all in a clean, minimal UI.

🛒 Download on the App Store:👉 QRShot on App Store

🚀 Features

🔤 Text to QR: Convert any text to a scannable QR code.

🖼️ Image to QR: Encode images (JPEG) into QR format — auto-compression supported!

🧠 QR Decoding: Paste any data:image/jpeg;base64,... payload to preview and save the original image.

🎨 Custom Colors: Pick foreground and background colors for your QR codes.

🕓 History Panel: View previously generated QR codes, with previews and easy sharing.

📤 Share & Save: Export generated QR images to your photo library or share with others.

🍎 Built entirely in SwiftUI + SwiftData with a local-first design.

📸 Screenshots

Encode Text

Generate From Image

QR History







Replace placeholder images with actual screenshots from your app.

🧑‍💻 Tech Stack

SwiftUI – modern declarative UI

SwiftData – lightweight Core Data alternative for local persistence

PhotosPicker – integrated iOS image selection

QRCode CoreImage filters – generating and coloring QR codes

UIKit interoperability – image compression and manipulation

Transferable – to export images easily

📂 Project Structure

QRShot/
├── ContentView.swift
├── QRShotApp.swift
├── QRShotItem.swift
├── QRCodeManager.swift
├── Extensions/
│   ├── UIColor+Hex.swift
│   ├── Color+Hex.swift
│   └── UIImage+Transferable.swift
└── Assets.xcassets/

🛠️ Installation

Clone the repo:

git clone https://github.com/YOUR_USERNAME/QRShot.git
cd QRShot

Open the project in Xcode:

open QRShot.xcodeproj

Run the app on a simulator or your iPhone.

📄 License

MIT License.Feel free to use, fork, and contribute!

💡 Author

Made with ❤️ by Sepehr Fazely📩 Questions? Open an issue or connect with me on LinkedIn


import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    // MARK: – Persistence
    @Environment(\.modelContext) private var context
    @Query(sort: \QRShotItem.created, order: .reverse) private var items: [QRShotItem]

    // MARK: – Shared UI state
    @State private var fgColor: Color = .primary
    @State private var bgColor: Color = .white
    @State private var image: UIImage?          // preview for generated/decoded image

    // Text‑to‑QR
    @State private var text = ""

    // Image‑to‑QR
    @State private var pickedPhoto: PhotosPickerItem?
    @State private var pickedUIImage: UIImage?

    // Decode‑from‑text
    @State private var decodeText = ""

    // Tabs
    enum Mode: String, CaseIterable { case text = "Text", photo = "Image", decode = "Decode" }
    @State private var mode: Mode = .text

    // Alert
    @State private var showTooLargeAlert   = false
    @State private var showDecodeFailAlert = false

    // MARK: – View
    var body: some View {
        NavigationStack {
            Form {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { Text($0.rawValue) }
                }
                .pickerStyle(.segmented)

                switch mode {
                case .text:   textSection
                case .photo:  imageSection
                case .decode: decodeSection
                }

                if let ui = image { previewSection(ui) }

                historySection
                colourSection
            }
            .navigationTitle("QRShot")
            .toolbar { EditButton() }
            .alert("Image is too large for a single QR‑code.",
                   isPresented: $showTooLargeAlert) { Button("OK", role: .cancel) { } }
            .alert("Couldn’t decode image data.",
                   isPresented: $showDecodeFailAlert) { Button("OK", role: .cancel) { } }
        }
    }

    // MARK: – Text‑to‑QR section
    private var textSection: some View {
        Section("Text to encode") {
            TextField("Enter text…", text: $text, axis: .vertical)
                .lineLimit(3, reservesSpace: true)

            Button("Generate QR") { generateTextQR() }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: – Image‑to‑QR section
    private var imageSection: some View {
        Section("Image to encode") {
            PhotosPicker(selection: $pickedPhoto,
                         matching: .images,
                         photoLibrary: .shared()) {
                HStack {
                    Label("Choose photo", systemImage: "photo")
                    if pickedUIImage != nil { Spacer(); Image(systemName: "checkmark.circle.fill") }
                }
            }
            .onChange(of: pickedPhoto) { _ in loadPickedImage() }

            Button("Generate QR") { generateImageQR() }
                .disabled(pickedUIImage == nil)
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: – Decode‑from‑text section
    private var decodeSection: some View {
        Section("Paste QR payload here") {
            TextEditor(text: $decodeText)
                .frame(minHeight: 80)

            Button("Decode Image") { decodeImage() }
                .disabled(!decodeText.lowercased().hasPrefix("data:image/"))
                .buttonStyle(.borderedProminent)
        }
    }

    // MARK: – Preview section
    private func previewSection(_ ui: UIImage) -> some View {
        Section("Preview") {
            Image(uiImage: ui)
                .resizable()
                .interpolation(.none)
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding()
                .contextMenu {
                    ShareLink(item: ui,
                              preview: SharePreview("QRShot", image: ui)) {
                        Label("Share image", systemImage: "square.and.arrow.up")
                    }
                }
        }
    }

    // MARK: – History section
    private var historySection: some View {
        Group {
            if !items.isEmpty {
                Section("History") {
                    ForEach(items) { item in
                        HStack {
                            if let thumb = QRCodeManager.thumbnail(
                                from: item.payload,
                                dim: 44,
                                foreground: UIColor(hex: item.fgHex),
                                background: UIColor(hex: item.bgHex)) {
                                Image(uiImage: thumb)
                                    .resizable()
                                    .interpolation(.none)
                                    .frame(width: 44, height: 44)
                            }
                            Text(item.payload.prefix(40)
                                 + (item.payload.count > 40 ? "…" : ""))
                                .lineLimit(1)
                        }
                        .contextMenu {
                            ShareLink(item: item.payload) {
                                Label("Copy payload", systemImage: "doc.on.doc")
                            }
                        }
                    }
                    .onDelete { index in
                        for i in index { context.delete(items[i]) }
                    }
                }
            }
        }
    }

    // MARK: – Colour pickers
    private var colourSection: some View {
        Section("Colours") {
            ColorPicker("Foreground", selection: $fgColor, supportsOpacity: false)
            ColorPicker("Background", selection: $bgColor, supportsOpacity: false)
        }
    }

    // MARK: – Text generator
    private func generateTextQR() {
        let payload = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !payload.isEmpty else { return }
        text = ""
        createQR(from: payload)
    }

    // MARK: – Image helpers (encode)
    private func loadPickedImage() {
        Task {
            if let data = try? await pickedPhoto?.loadTransferable(type: Data.self),
               let ui = UIImage(data: data) {
                pickedUIImage = ui
            }
        }
    }

    private func generateImageQR() {
        guard let ui = pickedUIImage else { return }
        pickedUIImage = nil

        guard let payload = jpegPayloadFittingQR(ui) else {
            showTooLargeAlert = true
            return
        }
        createQR(from: payload)
    }

    /// Shrink JPEG until payload ≤ 2 331 bytes (Version‑40 / M)
    private func jpegPayloadFittingQR(_ image: UIImage) -> String? {
        let prefix   = "data:image/jpeg;base64,"
        let maxBytes = 2_331 - prefix.utf8.count
        let minSide  = CGFloat(8)

        var current = image
        var quality = CGFloat(0.9)

        while true {
            guard let data = current.jpegData(compressionQuality: quality) else { return nil }
            let b64Len = (data.count + 2) / 3 * 4
            if b64Len <= maxBytes {
                return prefix + data.base64EncodedString()
            }
            if quality > 0.05 {
                quality = max(0.05, quality - 0.15)
                continue
            }
            let newW = current.size.width * 0.7
            let newH = current.size.height * 0.7
            if newW < minSide || newH < minSide { break }
            UIGraphicsBeginImageContextWithOptions(CGSize(width: newW, height: newH), true, 1)
            current.draw(in: CGRect(origin: .zero, size: CGSize(width: newW, height: newH)))
            guard let resized = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            UIGraphicsEndImageContext()
            current  = resized
            quality  = 0.9
        }
        return nil
    }

    // MARK: – Decode helper
    private func decodeImage() {
        let s = decodeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let range = s.range(of: "base64,") else { showDecodeFailAlert = true; return }
        let b64 = String(s[range.upperBound...])
        guard let data = Data(base64Encoded: b64),
              let ui   = UIImage(data: data) else { showDecodeFailAlert = true; return }

        // Preview and offer saving
        image = ui
        decodeText = ""

        Task.detached {
            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized else { return }
            try? await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: ui)
            }
        }
    }

    // MARK: – Core QR creation
    private func createQR(from payload: String) {
        let fgHex = fgColor.toHex()
        let bgHex = bgColor.toHex()

        Task.detached(priority: .userInitiated) {
            guard let qr = QRCodeManager.generate(
                    from: payload,
                    foreground: UIColor(hex: fgHex),
                    background: UIColor(hex: bgHex)) else { return }

            await MainActor.run {
                image = qr
                context.insert(QRShotItem(payload: payload,
                                          fgHex: fgHex,
                                          bgHex: bgHex))
            }

            let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
            guard status == .authorized else { return }
            try? await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: qr)
            }
        }
    }
}

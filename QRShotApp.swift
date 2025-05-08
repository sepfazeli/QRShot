import SwiftUI
import SwiftData

@main
struct QRShotApp: App {
    init() {
#if DEBUG
        // Silence UIKit constraint logs while debugging
        UserDefaults.standard.set(false,
            forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
#endif
    }

    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: QRShotItem.self)
    }
}

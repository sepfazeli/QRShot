import UIKit
import UniformTypeIdentifiers
import SwiftUI

extension UIImage: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { $0.pngData() ?? Data() }
    }
}

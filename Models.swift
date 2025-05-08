import Foundation
import SwiftData

@Model
final class QRShotItem {
    var created: Date
    var payload: String
    var fgHex: String
    var bgHex: String

    init(payload: String,
         fgHex: String = "#000000",
         bgHex: String = "#FFFFFF",
         created: Date = Date()) {
        self.created = created
        self.payload = payload
        self.fgHex   = fgHex
        self.bgHex   = bgHex
    }
}

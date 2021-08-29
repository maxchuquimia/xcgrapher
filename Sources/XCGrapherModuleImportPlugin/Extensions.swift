
import Foundation
import XCGrapherPluginSupport

extension XCGrapherImport.ModuleType {
    var customColor: String {
        switch self {
        case .target: return "#000000" // Black
        case .apple: return "#0071E3" // That classic Apple blue colour we all know
        case .spm: return "#F05138" // The orange of the Swift logo
        case .cocoapods: return "#380200" // The banner color from Cocoapods.org
        case .other: return "#FF0000" // Red (something went wrong)
        }
    }
}

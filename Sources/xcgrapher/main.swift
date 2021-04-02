
import Foundation
import XCGrapherLib

let options = XCGrapherArguments.parseOrExit()

do {
    try XCGrapherMain.run(with: options)
} catch {
    die(error.localizedDescription)
}

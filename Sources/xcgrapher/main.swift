
import Foundation
import XCGrapherLib

let options = XCGrapherArguments.parseOrExit()

do {
    try XCGrapher.run(with: options)
} catch {
    die(error.localizedDescription)
}

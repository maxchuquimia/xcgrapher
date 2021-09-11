
import XCTest
import XCGrapherPluginSupport
@testable import XCGrapherLib

final class DependencyManagerTests: XCTestCase {
    private struct Manager : DependencyManager, Equatable {
        private let isManaging: Bool

        init(isManaging: Bool) {
            self.isManaging = isManaging
        }

        func isManaging(module: String) -> Bool {
            return isManaging
        }

        func dependencies(of module: String) -> [String] {
            []
        }

        var pluginModuleType: XCGrapherImport.ModuleType { .cocoapods }
    }

    func testArrayExtensionToFindManagerOfModule() {
        let manager1 = Manager(isManaging: false)
        let manager2 = Manager(isManaging: true)
        let sut: [Manager] = [
            manager1,
            manager2,
        ]
        XCTAssertEqual(sut.manager(of: "anything"), manager2)
    }

}

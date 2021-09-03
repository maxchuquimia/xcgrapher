
import Foundation

extension Array {

    func appending(_ element: Element) -> [Element] {
        self + [element]
    }

}

extension Array where Element: Hashable {

    func unique() -> [Element] {
        Array(Set(self))
    }

}

extension Array where Element == String {

    func sortedAscendingCaseInsensitively() -> [String] {
        sorted { (a, b) -> Bool in
            let _a = a.lowercased()
            let _b = b.lowercased()
            return _a == _b ?  a < b : _a < _b
        }
    }

}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

import Foundation

extension Scanner {
    class Builder {
        private var operations: [(Scanner) -> String?] = []

        func scanUpTo(string: String) {
            operations.append { scanner -> String? in
                _ = scanner.scanUpToString(string)
                return nil
            }
        }

        func scanUpToAndIncluding(string: String) {
            operations.append { scanner -> String? in
                _ = scanner.scanUpToString(string)
                _ = scanner.scanString(string)
                return nil
            }
        }

        func scanAndStoreUpTo(string: String) {
            operations.append { scanner -> String? in
                scanner.scanUpToString(string)
            }
        }

        func scanAndStoreUpToCharacters(from set: CharacterSet) {
            operations.append { scanner -> String? in
                scanner.scanUpToCharacters(from: set)
            }
        }

        func scanAndStoreUpToAndIncluding(string: String) {
            operations.append { scanner -> String? in
                guard let part1 = scanner.scanUpToString(string) else { return nil }
                guard let part2 = scanner.scanString(string) else { return nil }
                return part1 + part2
            }
        }

        func execute(on string: String) -> String {
            var finalOutput = ""
            let scanner = Scanner(string: string)
            scanner.charactersToBeSkipped = nil // WHY does this have a default value!?
            for operation in operations {
                if let operationOutput = operation(scanner) {
                    finalOutput.append(operationOutput)
                }
            }
            return finalOutput
        }
    }
}

import Foundation

struct PackageDescription: Decodable {
    let name: String
    let path: String
    let targets: [Target]

    struct Target: Decodable {
        let name: String
        let path: String
        let sources: [String]
        let type: String
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        path = try values.decode(String.self, forKey: .path)
        // Map all target-related paths to be absolute.
        targets = try values.decode([Target].self, forKey: .targets).map { [path] target -> Target in
            let path = path.appendingPathComponent(target.path)
            let sources = target.sources.map { path.appendingPathComponent($0) }
            return Target(
                name: target.name,
                path: path,
                sources: sources,
                type: target.type
            )
        }

    }

    enum CodingKeys: String, CodingKey {
        case name, path, targets
    }
}

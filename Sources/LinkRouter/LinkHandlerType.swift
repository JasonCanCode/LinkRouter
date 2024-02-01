import Foundation

public protocol LinkHandlerType {
    /// Provides all possible paths a handler should respond to, with dynamic
    /// elements indicated with moustache placeholders.
    var pathSchemes: [String] { get }
    /// The first (unique) component of each pathScheme is used to determine
    /// whehter a LinkHandler shoudl claim responsibility.
    func canHandle(link: Link) -> Bool

    /// Inspect the link and perform the appropraite action.
    /// - Returns: Whether or not an action was performed using the link passed.
    func handle(link: Link) -> Bool
}

public extension LinkHandlerType {

    // MARK: - Computed Properties

    /// Provides a list of namespaces pulled from unique instances of the first component of the ``pathSchemes``.
    var roots: [String] {
        let rootComponents = pathSchemeCollection.compactMap { $0.first }
        let uniqueRoots = Array(Set(rootComponents))
        return uniqueRoots
    }

    private var parameterKeys: [String] {
        let allComponents = pathSchemeCollection.reduce([], +)
        let foundKeys = allComponents.filter(moustacheCheck)
        let uniqueKeys = Array(Set(foundKeys))

        return uniqueKeys
    }

    private var pathSchemeCollection: [[String]] {
        return pathSchemes.map { $0.components(separatedBy: "/") }
    }

    // MARK: - Handling Methods

    /// Indicates whether a link handler can properly route a provided ``Link``.
    func canHandle(link: Link) -> Bool {
        for root in roots where link.pathComponents.contains(root) {
            return true
        }
        return false
    }

    /// Compared the path components with path schemes to find parameters to add.
    /// - Parameter pathComponents: Elements of a URL
    /// - Parameter existingParams: Parameters already extracted from a query. Existing parameters supercede found values with the same key.
    /// - Returns: A `PathResult` containing all parameters and any path components found after the last extracted parameter.
    func parameterExtraction(from pathComponents: [String], existingParams: [String: String] = [:]) -> PathResult? {
        let longestSchemesFirst = pathSchemeCollection.sorted(by: { $0.count > $1.count })

        for schemeComponents in longestSchemesFirst {
            if let result = parameterExtraction(from: pathComponents, schemeComponents: schemeComponents) {

                var uniqueParams: [String: String] = existingParams
                for (key, value) in result.params where uniqueParams[key] == nil {
                    uniqueParams[key] = value
                }
                return PathResult(params: uniqueParams, trailingComponents: result.trailingComponents)
            }
        }
        return nil
    }
    // swiftlint:enable line_length

    private func parameterExtraction(from pathComponents: [String], schemeComponents: [String]) -> PathResult? {
        guard let indexKeyDic = keyIndicesDic(from: pathComponents, schemeComponents: schemeComponents),
            let lastIndex = indexKeyDic.keys.max(),
            lastIndex < pathComponents.count else {
                return nil
        }
        var params: [String: String] = [:]

        for (pathIndex, comp) in pathComponents.enumerated() {
            if let key = indexKeyDic[pathIndex] {
                params[key] = comp
            } else if comp != schemeComponents[pathIndex] {
                return nil
            }
        }

        if params.isEmpty {
            return nil
        }

        let trailingComponents: [String] = pathComponents.count > lastIndex + 1
            ? Array(pathComponents[lastIndex + 1..<pathComponents.count])
            : []

        return PathResult(params: params, trailingComponents: trailingComponents)
    }

    private func keyIndicesDic(from pathComponents: [String], schemeComponents: [String]) -> [Int: String]? {
        guard pathComponents.count == schemeComponents.count else {
            return nil
        }
        var keyIndices: [Int] = []
        var foundKeys: [String] = []

        for key in parameterKeys {
            if let index = schemeComponents.firstIndex(of: key) {
                foundKeys.append(removeMoustache(from: key))
                keyIndices.append(Int(index))
            }
        }

        if keyIndices.isEmpty {
            return nil
        }
        return Dictionary(uniqueKeysWithValues: zip(keyIndices, foundKeys))
    }

    private func moustacheCheck(_ text: String) -> Bool {
        return text.hasPrefix("{") && text.hasSuffix("}")
    }

    private func removeMoustache(from text: String) -> String {
        guard moustacheCheck(text) else {
            return text
        }
        var shaved = text
        shaved.removeFirst()
        shaved.removeLast()
        return shaved
    }
}

import Foundation

/// Contains all parameters found in a URL, both through dynamic elements within the path and those  found in a query.
/// Also provides any path components found after the last extracted parameter.
public struct PathResult {
    /// Properties found either in a query or extracted from a path scheme
    public let params: [String: String]
    /// Any path components found after the last extracted parameter
    public let trailingComponents: [String]
}

import Foundation

/// Converts a `URL` into a form ideal for use with a `LinkHandlerType`
public struct Link {
    /// The url from the original link request
    public let url: URL
    /**
     The relative path components being considered for resolving a handler.
     These are initially extracted from the original url. Typically the first element is matched against
     the available handlers. If matched, the request is passed to the handler.
     */
    public let pathComponents: [String]
    /**
     The query params. These are initially extracted from the original url.
     They may be processed or altered as needed during the routing process.
     */
    public let params: [String: String]

    private let appScheme: String?

    /// Separates and preserves the path components and parameters found in a URL
    /// - Parameter url: The url from the original link request
    /// - Parameter appScheme: Can be used to check against the url scheme and preserve the host
    public init(url: URL, appScheme: String?) {
        self.url = url
        self.appScheme = appScheme

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            self.pathComponents = []
            self.params = [:]
            return
        }

        var path = components.path.components(separatedBy: "/").dropFirst()
        if let host = components.host,
            let scheme = components.scheme,
            appScheme == scheme {

            path = [host] + path
        }

        var params = [String: String]()
        for param in components.queryItems ?? [] {
            params[param.name] = param.value
        }

        self.pathComponents = Array(path)
        self.params = params
    }

    /// Converts a deeplink formatted url into a standard one using the provided host
    /// - Parameter host: The desired host of the standardized link
    public func standardizedURL(forHost host: String) -> URL? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
            urlComponents.scheme == appScheme else {
            return url
        }
        urlComponents.scheme = "https"

        if let urlHost = urlComponents.host {
            urlComponents.path = "/" + urlHost + urlComponents.path
        }
        urlComponents.host = host
        urlComponents.query = "mobile=ios"

        return urlComponents.url
    }
}

public extension Link {
    
}

import Foundation

/// Manages all the link handlers and routes a url to the appropriate one.
public class LinkRouter: NSObject {
    /// A singleton instance to be used as the primary router for linking into the app.
    ///
    /// By default, this singleton will pull the primary custom scheme from the main bundle if
    ///  [defined.](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)
    /// If your app uses multiple URL types, you will need to manage your own instances of ``LinkRouter`` instead.
    public static let shared: LinkRouter = LinkRouter(appScheme: defaultScheme)

    /// The identifier used for deep linking into your app.
    ///
    /// For example, if the URL `MyApp://` would open MyApp, this would be "MyApp"
    public var appScheme: String?
    private var handlers: [LinkHandlerType] = []

    public init(appScheme: String? = nil) {
        self.appScheme = appScheme
    }

    /// Convert a web link url to an app link url, if possible
    public func convertUrlToAppLink(url: URL?) -> URL? {
        guard let appScheme = appScheme,
            let validURL = url,
            let scheme = validURL.scheme,
            scheme.starts(with: "http"),
            let applinkURL = URL(string: "\(appScheme):/\(validURL.path)") else {
                return url
        }

        return applinkURL
    }

    /// Checks if it has a router that can handle the url
    /// - Parameter url: The url from the original link request
    public func canHandle(url: URL) -> Bool {
        for handler in handlers {

            let link = Link(url: url, appScheme: appScheme)
            if handler.canHandle(link: link) {
                return true
            }
        }
        return false
    }

    /**
      Route an open url link request to a matched LinkHandler
    - Parameter url: The url from the original link request
    - Returns: true if the link was handled; false otherwise
    */
    @discardableResult
    public func route(url: URL) -> Bool {
        let link = Link(url: url, appScheme: appScheme)

        guard let handler = handlers.first(where: { $0.canHandle(link: link) }) else {
            return false
        }
        return handler.handle(link: link)
    }

    public func addHandler(_ handler: LinkHandlerType) {
        self.handlers.append(handler)
    }
}

// MARK: - Helpers

private var defaultScheme: String? {
    if let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]],
       let firstTypeSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String] {

        return firstTypeSchemes.first
    }
    return nil
}

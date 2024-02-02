# LinkRouter

A streamlined structure for inspecting a link and informing the right coordinator to take action.

## Overview

This framework provides a structure for establishing universal/deep linking in your app that is easy to follow. While your codebase will naturally require some kind of navigation structure to allow for the presentation of a specific view, this framework can work with many different structures. Follow these steps to have your app routing to feature from links today.

1. [Define a Custom URL Scheme](define-a-custom-url-scheme)
2. [Create a Link Handler](create-a-link-handler)
3. [Define a Coordinator](define-a-coordinator)

Once you have your handler(s) and coordinator(s) in place, routing from a URL is as simple as...

```swift
extension MyAppDelegate {

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // 🔗🪄
        return LinkRouter.shared.route(url: url)
    }
}
```
_OR_
```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 🔗🪄
                .onOpenURL(LinkRouter.shared.route) 
        }
    }
}
```

## Define a Custom URL Scheme

You will need to [define a custom URL scheme for your app](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app). By default, the `LinkRouter.shared` singleton will pull your scheme from the main bundle. If your app uses multiple URL types, you will need to manage your own instances of `LinkRouter` instead. In addition, the router should be able to handle any number of [associated domains](https://developer.apple.com/documentation/xcode/configuring-an-associated-domain) if you also have a website supporting univeral linking.

## Create a Link Handler

Let's imagine we have an app for board game enthusiasts. Users can keep track of games they own, write reviews, and read the reviews of other users. We want to be able to deeplink into the app to see a user's game collection, what reviews they've written, as well as all reviews of a particular game. The website already has pages under the "games" relative path (ex. `https://www.mysite.com/games`). We can follow the same path conventions when setting up our handler.

```swift
struct GamesLinkHandler {
    let coordinator: GamesLinkCoordinator
    let pathSchemes: [String] = [
        "games",
        "games/{username}",
        "games/{username}/reviews",
        "games/reviews/{game}"
    ]
}
```

Notice that dynamic elements of a path are indicated using "moustache" notation. These elements will be extracted when coverted to a `PathResult` and added to the `params` along with any queries included in a URL.

Our `GamesLinkCoordinator` should align with our unique paths, providing a presentation solution for each case.

```swift
protocol GamesLinkCoordinator {
    func showGameHomecreen()
    func showGameCollection(of username: String)
    func showGameReviews(by username: String)
    func showGameReview(of game: String)
}
```

The only thing left to  make our handler a proper `LinkHandlerType` is to provide our function to handle a link.

```swift
extension GamesLinkHandler: LinkHandlerType {

    func handle(link: Link) -> Bool {
        guard let result = result(forLink: link) else {
            return false
        }
        
        if let username = result.params["username"] {
            handle(username: username, result: result)
        } else if let game = result.params["game"], link.pathComponents.contains("reviews") {
            coordinator.showGameReview(of: game)
        } else {
            coordinator.showGameHomecreen()
        }
        
        return true
    }

    /// Handles paths with a dynamic username
    private func handle(username: String, result: PathResult) {
        if result.trailingComponents.contains("reviews") {
            coordinator.showGameReviews(by: username)
        } else {
            coordinator.showGameCollection(of: username)
        }
    }
}
```

## Define a Coordinator

We have the requirements for our link coordinator. Now we need to have a key player of whatever navigation solution you are using provide your feature presentation solutions. Whether it is a `PrimaryNavigationController` or `MainTabController` or `AppCoordinator`, it will need to adhere to any link coordinator protocols you have declared for your link handlers. 

Lastly, you will need to register your concrete coordinator(s) with `LinkRouter`. This should be done as soon in your app's life cycle as possible to ensure your app will always have a response ready when being opened by a link. One option is to include this as a side effect when constructing your navigation solution.

```swift
public let appCoordinator: AppCoordinator = {
    let coordinator = AppCoordinator()
    let linkHandler = GamesLinkHandler(coordinator: coordinator)
    LinkRouter.shared.addHandler(linkHandler)
        
    return coordinator
}()
```

import Foundation
import LinkRouter

protocol GamesLinkCoordinator {
    func showGameHomecreen()
    func showGameCollection(of username: String)
    func showGameReviews(by username: String)
    func showGameReview(of game: String)
}

struct GamesLinkHandler: LinkHandlerType {
    let coordinator: GamesLinkCoordinator
    let pathSchemes: [String] = [
        "games",
        "games/{username}",
        "games/{username}/reviews",
        "games/reviews/{game}"
    ]

    func handle(link: Link) -> Bool {
        guard let result = result(forLink: link) else {
            coordinator.showGameHomecreen()
            return true
        }
        if let username = result.params["username"] {
            handle(username: username, result: result)
        } else if let game = result.params["game"], link.pathComponents.contains("reviews") {
            coordinator.showGameReview(of: game)
        }
        return true
    }

    private func handle(username: String, result: PathResult) {
        if result.trailingComponents.contains("reviews") {
            coordinator.showGameReviews(by: username)
        } else {
            coordinator.showGameCollection(of: username)
        }
    }
}

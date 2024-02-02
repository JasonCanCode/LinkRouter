import Foundation
import LinkRouter

class MockCoordinator {
    private(set) var verdict: Verdict? = nil
    private(set) var dynamicElement: String? = nil

    enum Verdict {
        case games
        case usersGames
        case usersReviews
        case gameReviews
    }

    func reset() {
        verdict = nil
        dynamicElement = nil
    }
}

extension MockCoordinator: GamesLinkCoordinator {

    func showGameHomecreen() {
        verdict = .games
    }

    func showGameCollection(of username: String) {
        verdict = .usersGames
        dynamicElement = username
    }

    func showGameReviews(by username: String) {
        verdict = .usersReviews
        dynamicElement = username
    }

    func showGameReview(of game: String) {
        verdict = .gameReviews
        dynamicElement = game
    }
}

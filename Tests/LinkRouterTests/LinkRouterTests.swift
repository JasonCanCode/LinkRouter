import XCTest
@testable import LinkRouter

final class LinkRouterTests: XCTestCase {
    var router: LinkRouter!
    let coordinator = MockCoordinator()

    override func setUp() async throws {
        router = LinkRouter(appScheme: "test-app")
        router.addHandler(GamesLinkHandler(coordinator: coordinator))
    }

    override func tearDown() async throws {
        router = nil
        coordinator.reset()
    }

    func testAppLink_Games() throws {
        try assert(
            path: "https://www.test-app.com/games",
            resultsIn: .games
        )
    }

    func testDeepLink_Games() throws {
        try assert(
            path: "test-app:/games",
            resultsIn: .games
        )
    }

    func testAppLink_UsersGames_PathElement() throws {
        try assert(
            path: "https://www.test-app.com/games/KeyMaster",
            resultsIn: .usersGames,
            withDynamicElement: "KeyMaster"
        )
    }

    func testDeepLink_UsersGames_PathElement() throws {
        try assert(
            path: "test-app:/games/KeyMaster",
            resultsIn: .usersGames,
            withDynamicElement: "KeyMaster"
        )
    }

    func testAppLink_UsersGames_QueryElement() throws {
        try assert(
            path: "https://www.test-app.com/games?username=KeyMaster",
            resultsIn: .usersGames,
            withDynamicElement: "KeyMaster"
        )
    }

    func testDeepLink_UsersGames_QueryElement() throws {
        try assert(
            path: "test-app://games?username=KeyMaster",
            resultsIn: .usersGames,
            withDynamicElement: "KeyMaster"
        )
    }

    func testAppLink_UsersReviews_PathElement() throws {
        try assert(
            path: "https://www.test-app.com/games/KeyMaster/reviews",
            resultsIn: .usersReviews,
            withDynamicElement: "KeyMaster"
        )
    }

    func testDeepLink_UsersReviews_PathElement() throws {
        try assert(
            path: "test-app:/games/KeyMaster/reviews",
            resultsIn: .usersReviews,
            withDynamicElement: "KeyMaster"
        )
    }

    func testAppLink_GameReviews_PathElement() throws {
        try assert(
            path: "https://www.test-app.com/games/reviews/Lords-of-Waterdeep",
            resultsIn: .gameReviews,
            withDynamicElement: "Lords-of-Waterdeep"
        )
    }

    func testDeepLink_GameReviews_PathElement() throws {
        try assert(
            path: "test-app:/games/reviews/Lords-of-Waterdeep",
            resultsIn: .gameReviews,
            withDynamicElement: "Lords-of-Waterdeep"
        )
    }

    func testAppLink_GameReviews_QueryElement() throws {
        try assert(
            path: "https://www.test-app.com/games/reviews?game=Lords-of-Waterdeep",
            resultsIn: .gameReviews,
            withDynamicElement: "Lords-of-Waterdeep"
        )
    }

    func testDeepLink_GameReviews_QueryElement() throws {
        try assert(
            path: "test-app://games/reviews?game=Lords-of-Waterdeep",
            resultsIn: .gameReviews,
            withDynamicElement: "Lords-of-Waterdeep"
        )
    }

    func testDeepLink_GameReviews_WrongScheme() throws {
        try assert(
            path: "myotherapp://games/reviews/Lords-of-Waterdeep",
            resultsIn: .gameReviews,
            withDynamicElement: "Lords-of-Waterdeep"
        )
    }
}

private extension LinkRouterTests {

    func assert(
        path: String,
        resultsIn verdict: MockCoordinator.Verdict,
        withDynamicElement element: String? = nil
    ) throws {
        let url = try XCTUnwrap(URL(string: path))
        router.route(url: url)
        XCTAssertEqual(coordinator.verdict, verdict)
        XCTAssertEqual(coordinator.dynamicElement, element)
    }
}

func testFetchCharactersHTTPError500() async {
    // GIVEN: Stub a 500 server error response
    stub(condition: isHost("swapi.dev")) { _ in
        HTTPStubsResponse(data: Data(), statusCode: 500, headers: nil)
    }

    // WHEN/THEN: Should throw an HTTP error with status 500
    await XCTAssertThrowsErrorAsync(
        try await repository.fetchCharacters(),
        "Should throw HTTP error for 500"
    ) { error in
        guard case RepositoryError.httpError(let statusCode) = error else {
            XCTFail("Expected RepositoryError.httpError, got \(error)")
            return
        }
        XCTAssertEqual(statusCode, 500, "Status code should be 500")
    }
}
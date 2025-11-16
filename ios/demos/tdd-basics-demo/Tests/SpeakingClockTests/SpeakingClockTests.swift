import XCTest
@testable import tdd_basics_demo

final class SpeakingClockTests: XCTestCase {
    func testSayTime() {
        // Arrange
        let mockClock = ClockMock()
        let mockSpeechSynthesizer = SpeechSynthesizerMock()
        let mockConverter = TimeToTextConverterMock()

        let speakingClock = SpeakingClock(clock: mockClock, speechSynthesizer: mockSpeechSynthesizer, converter: mockConverter)

        let testDate = Date(timeIntervalSince1970: 0) // Fixed date for testing
        mockClock.stubbedTime = testDate
        mockConverter.stubbedText = "Midnight"

        // Act
        speakingClock.sayTime()

        // Assert
        XCTAssertEqual(mockClock.getTimeCallCount, 1)
        XCTAssertEqual(mockConverter.convertTimeToTextCallCount, 1)
        XCTAssertEqual(mockSpeechSynthesizer.speakCallCount, 1)
        XCTAssertEqual(mockSpeechSynthesizer.spokenText, "Midnight")
    }
}

// MARK: - Mocks

class ClockMock: Clock {
    var stubbedTime: Date = Date()
    private(set) var getTimeCallCount = 0

    override func getTime() -> Date {
        getTimeCallCount += 1
        return stubbedTime
    }
}

class SpeechSynthesizerMock: SpeechSynthesizer {
    private(set) var speakCallCount = 0
    private(set) var spokenText: String?

    override func speak(_ text: String) {
        speakCallCount += 1
        spokenText = text
    }
}

class TimeToTextConverterMock: TimeToTextConverter {
    var stubbedText: String?
    private(set) var convertTimeToTextCallCount = 0

    override func convertTimeToText(_ date: Date) -> String? {
        convertTimeToTextCallCount += 1
        return stubbedText
    }
}
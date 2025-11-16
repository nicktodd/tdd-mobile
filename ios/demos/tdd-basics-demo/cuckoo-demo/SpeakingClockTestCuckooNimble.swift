import XCTest
import Cuckoo
import Nimble
@testable import SpeakingClock

final class SpeakingClockTestCuckooNimble: XCTestCase {
    func testSayTimeWithCuckooAndNimble() {
        // Arrange
        let mockClock = MockClock()
        let mockSpeechSynthesizer = MockSpeechSynthesizer()
        let mockConverter = MockTimeToTextConverter()

        let speakingClock = SpeakingClock(clock: mockClock, speechSynthesizer: mockSpeechSynthesizer, converter: mockConverter)

        let testDate = Date(timeIntervalSince1970: 0) // Fixed date for testing
        let testText = "Midnight"

        // Stub methods
        stub(mockClock) { stub in
            when(stub.getTime()).thenReturn(testDate)
        }
        stub(mockConverter) { stub in
            when(stub.convertTimeToText(testDate)).thenReturn(testText)
        }

        // Act
        speakingClock.sayTime()

        // Assert
        expect(mockClock).to(haveReceived("getTime"))
        expect(mockConverter).to(haveReceived("convertTimeToText").with(testDate))
        expect(mockSpeechSynthesizer).to(haveReceived("speak").with(testText))
    }
}

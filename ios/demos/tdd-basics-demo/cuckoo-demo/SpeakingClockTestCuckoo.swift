import XCTest
import Cuckoo
@testable import SpeakingClock

final class SpeakingClockTestCuckoo: XCTestCase {
    func testSayTimeWithCuckoo() {
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
        verify(mockClock).getTime()
        verify(mockConverter).convertTimeToText(testDate)
        verify(mockSpeechSynthesizer).speak(testText)
    }
}
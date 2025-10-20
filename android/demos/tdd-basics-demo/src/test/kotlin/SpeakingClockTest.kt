import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.shouldBe
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import java.time.LocalTime

class SpeakingClockTest : StringSpec({

    "should convert time to text and speak it" {
        // Arrange
        val mockClock = mockk<Clock>()
        val mockSpeechEngine = mockk<SpeechEngine>(relaxed = true)
        val mockConverter = mockk<TimeToTextConverter>()
        val speakingClock = SpeakingClock(mockClock, mockSpeechEngine, mockConverter)

        val testTime = LocalTime.of(12, 0)
        val testTimeAsText = "Noon"
        every { mockClock.getTime() } returns testTime
        every { mockConverter.convertTimeToText(testTime) } returns testTimeAsText

        // Act
        speakingClock.sayTime()

        // Assert
        verify { mockClock.getTime() }
        verify { mockConverter.convertTimeToText(testTime) }
        verify { mockSpeechEngine.speak(testTimeAsText) }
    }
})
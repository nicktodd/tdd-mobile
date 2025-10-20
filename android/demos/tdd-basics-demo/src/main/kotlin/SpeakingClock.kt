class SpeakingClock(
        private val clock: Clock,
        private val speechEngine: SpeechEngine,
        private val converter: TimeToTextConverter
) {
    fun sayTime() {
        val time = clock.getTime()
        val timeAsText = converter.convertTimeToText(time)
        speechEngine.speak(timeAsText)
    }
}

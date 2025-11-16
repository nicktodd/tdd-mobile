import Foundation

class SpeakingClock {
    private let clock: Clock
    private let speechSynthesizer: SpeechSynthesizer
    private let converter: TimeToTextConverter

    init(clock: Clock, speechSynthesizer: SpeechSynthesizer, converter: TimeToTextConverter) {
        self.clock = clock
        self.speechSynthesizer = speechSynthesizer
        self.converter = converter
    }

    func sayTime() {
        let time = clock.getTime()
        if let timeAsText = converter.convertTimeToText(time) {
            speechSynthesizer.speak(timeAsText)
        }
    }
}
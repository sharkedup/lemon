import AVFoundation

final class Speaker {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.pitchMultiplier = 1.25
        utterance.rate = 0.47
        synthesizer.speak(utterance)
    }
}

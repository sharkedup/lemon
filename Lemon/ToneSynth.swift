import AVFoundation

final class ToneSynth {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44100
    private let format: AVAudioFormat

    init() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif

        format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    func play(frequency: Double, duration: Double = 0.18) {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        let channel = buffer.floatChannelData![0]
        let angularFrequency = 2.0 * Double.pi * frequency
        let fadeSamples = 200.0

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let fadeIn = min(1.0, Double(frame) / fadeSamples)
            let fadeOut = min(1.0, Double(Int(frameCount) - frame) / fadeSamples)
            let envelope = min(fadeIn, fadeOut)
            channel[frame] = Float(sin(angularFrequency * t) * 0.2 * envelope)
        }

        player.scheduleBuffer(buffer, completionHandler: nil)
        if !player.isPlaying {
            player.play()
        }
    }
}

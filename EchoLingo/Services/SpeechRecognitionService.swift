import Foundation
import AVFoundation
import Speech

enum PermissionState {
    case unknown
    case granted
    case denied
}

@MainActor
final class SpeechRecognitionService: NSObject {
    enum SpeechError: LocalizedError {
        case recognizerUnavailable
        case permissionDenied
        case microphonePermissionDenied
        case audioEngineFailure
        case invalidAudioFormat
        case simulatorUnsupported

        var errorDescription: String? {
            switch self {
            case .recognizerUnavailable:
                return "Speech recognizer is unavailable for the selected language right now."
            case .permissionDenied:
                return "Speech Recognition permission was denied. Please enable it in Settings."
            case .microphonePermissionDenied:
                return "Microphone permission was denied. Please enable it in Settings."
            case .audioEngineFailure:
                return "Failed to start the audio engine."
            case .invalidAudioFormat:
                return "Microphone input format is unavailable."
            case .simulatorUnsupported:
                return "Speech recognition requires a real device microphone. Run EchoLingo on an iPhone or iPad."
            }
        }
    }

    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer?

    func microphonePermissionState() async -> PermissionState {
        await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }

    func speechPermissionState() -> PermissionState {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return .granted
        case .denied, .restricted:
            return .denied
        case .notDetermined:
            return .unknown
        @unknown default:
            return .unknown
        }
    }

    func requestPermissions() async throws {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else {
            throw SpeechError.permissionDenied
        }

        let micGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        guard micGranted else {
            throw SpeechError.microphonePermissionDenied
        }
    }

    func startRecognition(locale: Locale, onResult: @escaping (String, Bool) -> Void) throws {
        stopRecognition()

#if targetEnvironment(simulator)
        throw SpeechError.simulatorUnsupported
#else
        guard let recognizer = SFSpeechRecognizer(locale: locale), recognizer.isAvailable else {
            throw SpeechError.recognizerUnavailable
        }
        self.recognizer = recognizer

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 18.0, *) {
            request.addsPunctuation = true
        }
        self.request = request

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.inputFormat(forBus: 0)
        guard inputFormat.sampleRate > 0, inputFormat.channelCount > 0 else {
            throw SpeechError.invalidAudioFormat
        }

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { [weak request] buffer, _ in
            request?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            throw SpeechError.audioEngineFailure
        }

        task = recognizer.recognitionTask(with: request) { result, error in
            if let result {
                onResult(result.bestTranscription.formattedString, result.isFinal)
            }

            if error != nil {
                self.stopRecognition()
            }
        }
#endif
    }

    func stopRecognition() {
        task?.cancel()
        task = nil

        request?.endAudio()
        request = nil

        if audioEngine.isRunning {
            audioEngine.stop()
        }

        audioEngine.inputNode.removeTap(onBus: 0)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

// 
//   SpeechText.swift
//   MapChat
// 
//   Created by iosdev on 3.12.2023.
// 

import Speech
import SwiftUI

enum AuthorizationError: Error {
    case deniedOrRestricted
    case notDetermined
    case unknown
}

actor SpeechRecognizer: ObservableObject {
    
    private let speechRecognizer: SFSpeechRecognizer?
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    @MainActor var transcript: String = ""
    
    init() {
        speechRecognizer = SFSpeechRecognizer()
        guard speechRecognizer != nil else {
            print("Speechrecognizer nil")
            return
        }
        
        Task {
            do {
                await requestSpeechRecognitionAuthorization { result in
                    switch result {
                    case .success:
                        print("Winner")
                    case .failure(let error):
                        switch error {
                        case .deniedOrRestricted:
                            print("loser")
                        case .notDetermined:
                            print("Dunno")
                        case .unknown:
                            print("How tho")
                        }
                    }
                }
                
                AVAudioSession.sharedInstance().requestRecordPermission { authStatus in
                    OperationQueue.main.addOperation {
                        switch authStatus {
                        case true:
                            print("Winner")
                        case false:
                            print("Loser")
                        }
                    }
                }
            }
        }
    }
    // Starts listening
    @MainActor func start() {
        Task {
            await startRecognition()
        }
    }
    // Stops listening
    @MainActor func stop() {
        Task {
            await stopRecognition()
        }
    }
    //  Sets up the audio engine and recognition request for speech recognition.
    private func setupEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let engine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try session.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = engine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        engine.prepare()
        try engine.start()
        
        return (engine, request)
    }
    //  Begins the speech recognition process
    private func startRecognition() {
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            print("Recognizer not available")
            return
        }
        do {
            let (engine, request) = try setupEngine()
            
            audioEngine = engine
            recognitionRequest = request
            
            recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let bestTranscription = result.bestTranscription.formattedString
                    
                    Task { [weak self] in
                        guard let self = self else { return }
                        self.updateTranscript(_: bestTranscription)
                    }
                }
                
                if let error = error {
                    print("Recognition error: \(error)")
                }
            }
        } catch {
            print("Error setting up recognition: \(error)")
        }
    }
    // Handles the request for speech recognition authorization
    func requestSpeechRecognitionAuthorization(completion: @escaping (Result<Void, AuthorizationError>) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                completion(.success(()))
            case .denied, .restricted:
                completion(.failure(.deniedOrRestricted))
            case .notDetermined:
                completion(.failure(.notDetermined))
            @unknown default:
                completion(.failure(.unknown))
            }
        }
    }
    // Handles the request for audio recording permission
    func requestRecordPermission(completion: @escaping (Result<Void, AuthorizationError>) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { authStatus in
            switch authStatus {
            case true:
                completion(.success(()))
            case false:
                completion(.failure(.deniedOrRestricted))
            }
        }
    }
    
    //  Updates the transcript with the received speech recognition results.
    nonisolated private func updateTranscript(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    
    //  Stops the ongoing speech recognition process and audio engine.
    func stopRecognition() {
        recognitionTask?.cancel()
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
}

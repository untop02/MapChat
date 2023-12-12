// 
//   ListenButton.swift
//   MapChat
// 
//   Created by iosdev on 3.12.2023.
// 

import Foundation
import SwiftUI
// Button to start and stop Speech2Text
struct ListenButton: View {
    @Binding var isListening: Bool
    @Binding var textField: String
    @Binding var isSpeechRecognitionActive: Bool
    let speechRecognizer: SpeechRecognizer
    
    var body: some View {
        Button {
            isListening.toggle()
            if isListening {
                speechRecognizer.transcript = ""
                speechRecognizer.start()
                isSpeechRecognitionActive = true
            } else {
                speechRecognizer.stop()
                isSpeechRecognitionActive = false

            }
        } label: {
            Image(systemName: isListening ? "mic.slash" : "mic")
                .foregroundColor(isSpeechRecognitionActive && !isListening ? .gray : .blue)
                .frame(width: 30, height: 30)
        }
        .overlay(
            Circle()
                .stroke(isSpeechRecognitionActive && !isListening ? .gray : .blue, lineWidth: 2)
        )
        .onChange(of: isListening) { newValue in
            if newValue {
                Task {
                    while isListening {
                        try await Task.sleep(nanoseconds: 100)
                        textField = speechRecognizer.transcript
                    }
                }
            }
        }
    }
}

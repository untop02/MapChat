//
//  ListenButton.swift
//  MapChat
//
//  Created by iosdev on 3.12.2023.
//

import Foundation
import SwiftUI

struct ListenButton: View {
    @Binding var isListening: Bool
    @Binding var textField: String
    let speechRecognizer: SpeechRecognizer
    
    var body: some View {
        Button {
            isListening.toggle()
            if isListening {
                speechRecognizer.transcript = ""
                speechRecognizer.start()
            } else {
                speechRecognizer.stop()
            }
        } label: {
            Image(systemName: isListening ? "mic.slash" : "mic")
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
        }
        .overlay(
            Circle()
                .stroke(Color.blue, lineWidth: 2)
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

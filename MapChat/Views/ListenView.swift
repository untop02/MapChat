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
    //let speechRecognizer: SpeechToTextActor
    let speechRecognizer: SpeechRecognizer
    
    var body: some View {
        TimerView(isListening: $isListening)
        Button {
            isListening.toggle()
            if isListening {
                speechRecognizer.start()
            } else {
                speechRecognizer.stop()
            }
        } label: {
            Image(systemName: isListening ? "mic.slash" : "mic")
        }
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


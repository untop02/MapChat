//
//  CustomTextField.swift
//  MapChat
//
//  Created by iosdev on 1.12.2023.
//

import SwiftUI
struct PlaceholderableTextField: View {
    @Binding var text: String
    //let speechRecognizer: SpeechToText
    let speechRecognizer: SpeechRecognizer
    @State var isListening = false
    let placeholder: String
    let axis: Axis
    let maxCharacterCount: Int
    @Binding var isSpeechRecognitionActive: Bool
    
    var body: some View {
        HStack {
            VStack {
                TextField(placeholder, text: $text, axis: axis)
                    .multilineTextAlignment(.center)
                    .padding(.leading)
                    .padding(.vertical , 7)
                    .font(.system(size: 15))
                    .onChange(of: text) { newValue in
                        if newValue.count > maxCharacterCount {
                            text = String(newValue.prefix(maxCharacterCount))
                        }
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(.gray, lineWidth: 1)
                    )
            }
            ListenButton(isListening: $isListening, textField: $text, isSpeechRecognitionActive: $isSpeechRecognitionActive, speechRecognizer: speechRecognizer)
                .disabled(isSpeechRecognitionActive && !isListening)
        }
        .padding([.top,.horizontal])
        TimerView(isListening: $isListening, isSpeechRecognitionActive: $isSpeechRecognitionActive)
    }
}

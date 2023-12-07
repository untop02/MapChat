//
//  CustomTextField.swift
//  MapChat
//
//  Created by iosdev on 1.12.2023.
//

import SwiftUI
struct PlaceholderableTextField: View {
    // FU APPLE : )
    @Binding var text: String
    @State var isListening = false
    let placeholder: String
    let axis: Axis
    let speechRecognizer: SpeechRecognizer
    let maxCharacterCount: Int
    
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
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            ListenButton(isListening: $isListening, textField: $text, speechRecognizer: speechRecognizer)
        }
        .navigationTitle("Search")
        .padding(.top)
        .padding(.horizontal)
    }
}

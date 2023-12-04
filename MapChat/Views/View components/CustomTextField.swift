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
    let placeholder: String
    let axis: Axis
    
    @FocusState private var isFocused: Bool
    var body: some View {
        ZStack {
            if text == "" {
                Text(placeholder).opacity(0.5).padding(.vertical, 7)
            }
            TextField("", text: $text, axis: axis)
                .focused($isFocused)
                .padding(.vertical, 7)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
        }
    }
}

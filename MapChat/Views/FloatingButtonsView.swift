//
//  FloatingButtonsView.swift
//  MapChat
//
//  Created by iosdev on 22.11.2023.
//

import SwiftUI

struct FloatingButtonsView: View {
    @ObservedObject var viewModel: MapViewModel
    //@StateObject var speechRecognizer = SpeechToTextActor()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var isShowingOverlay: Bool
    @Binding var isShowingSearch: Bool
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var showLocationPrompt = false
    @Binding var searchText: String
    @Binding var isAuthorized: Bool
    @State private var isListening = false
    
    var isFormValid: Bool {
        return !name.isEmpty
    }
    
    var body: some View {
        VStack(){
            HStack(){
                if !isShowingOverlay {
                    Button(action: {
                        isShowingOverlay.toggle()
                    }) {
                        Image(systemName: "list.bullet").font(.system(size: 35)).foregroundColor(Color.black).shadow(color: Color.black, radius: 4, x: 0, y: 3)}.padding()
                    Spacer()
                    WeatherView(isAuthorized: $isAuthorized)
                    Button(action: {
                        isShowingSearch.toggle()
                    }) {
                        Image(systemName: "magnifyingglass").font(.system(size: 25)).foregroundColor(Color.black).frame(width: 45, height: 45).overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.black, lineWidth: 2)
                        ) .shadow(color: Color.black, radius: 4, x: 0, y: 3)}.padding()
                } else {
                    Button(action: {
                        isShowingOverlay.toggle()
                    }) {
                        Image(systemName: "arrow.left").font(.system(size: 35)).foregroundColor(Color.black).shadow(color: Color.black, radius: 4, x: 0, y: 3)}.padding(22)
                    Spacer()
                }
            }
            if(isShowingSearch){ NavigationStack {
                Text("Searching for \(searchText)")
            }
                .searchable(text: $searchText, prompt: "Look for something").padding().background(Color.clear)}
            Spacer()
            HStack(){
                if !isShowingOverlay {
                    Button(action: {
                        viewModel.centerMapOnUserLocation()
                    }) {
                        Image(systemName: "location.north.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32).padding()
                    }
                        Spacer()
                        Button(action: {
                            print("plus perfect")
                            showLocationPrompt.toggle()
                        }) {
                            Image(systemName: "plus").font(.system(size: 30))
                                .frame(width: 85, height: 85)
                                .foregroundColor(Color.black)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: Color.black, radius: 4, x: 0, y: 3)
                        }
                        .sheet(isPresented: $showLocationPrompt) {
                            VStack {
                                PlaceholderableTextField(text: $name, placeholder: "Enter name", axis: Axis.vertical)
                                PlaceholderableTextField(text: $description, placeholder: "Enter description", axis: Axis.vertical)
                                ListenButton(isListening: $isListening, textField: $name, speechRecognizer: speechRecognizer)
                                Button("Save") {
                                    showLocationPrompt = false
                                    viewModel.createMapMarker(name: name, description: description)
                                    name = ""
                                    description = ""
                                }
                                .buttonStyle(.bordered)
                                .padding()
                                .disabled(!isFormValid)
                            }
                            .presentationDetents([.height(500)])
                    }.padding()
                }
            }
        }
    }
}

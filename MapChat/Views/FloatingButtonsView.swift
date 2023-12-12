//
//  FloatingButtonsView.swift
//  MapChat
//
//  Created by iosdev on 22.11.2023.
//

import SwiftUI

struct FloatingButtonsView: View {
    @ObservedObject var mapViewModel: MapViewModel
    @StateObject private var viewSearchModel = ContentViewModel()
    @Binding var isShowingOverlay: Bool
    @Binding var isShowingSearch: Bool
    @Binding var searchText: String
    @Binding var isAuthorized: Bool
    
    var body: some View {
        VStack {
            UpperButtons(mapViewModel: mapViewModel, viewSearchModel: viewSearchModel, isShowingOverlay: $isShowingOverlay, isShowingSearch: $isShowingSearch, isAuthorized: $isAuthorized)
            Spacer()
            LowerButtons(isShowingOverlay: $isShowingOverlay, mapViewModel: mapViewModel)
        }
    }
}
struct UpperButtons: View {
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var viewSearchModel: ContentViewModel
    @Binding var isShowingOverlay: Bool
    @Binding var isShowingSearch: Bool
    @Binding var isAuthorized: Bool
    private let duration = 0.2
    
    //view for the buttons on screen with map
    var body: some View {
        HStack() {
            //hiding buttons if menu is open
            if !isShowingOverlay {
                Button(action: {
                    isShowingOverlay.toggle()
                    isShowingSearch = false
                }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 35))
                        .foregroundColor(.black)
                        .shadow(color: .black, radius: 4, x: 0, y: 3)
                        .padding(.leading, 20)
                }
                Spacer()
                //checking if weather api has location permission
                WeatherView(isAuthorized: $isAuthorized)
                Button(action: {
                    isShowingSearch.toggle()
                    isShowingOverlay = false
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 25))
                        .foregroundColor(.black)
                        .frame(width: 45, height: 45)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(.black, lineWidth: 2)
                        )
                        .shadow(color: .black, radius: 4, x: 0, y: 3)
                        .padding(.trailing, 20)
                }
            } else {
                Button(action: {
                    isShowingOverlay.toggle()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 35))
                        .foregroundColor(.black)
                    .shadow(color: .black, radius: 4, x: 0, y: 3)}.padding(22)
                Spacer()
            }
        }
        
        //search for places around the map
        .sheet(isPresented: $isShowingSearch){
            VStack(alignment: .leading) {
                TextField("Enter City", text: $viewSearchModel.cityText)
                Divider()
                TextField("Enter Point of interest name", text: $viewSearchModel.poiText)
                Divider()
                Text("Results")
                    .font(.title)
                List(viewSearchModel.viewData) { item in
                    VStack(alignment: .leading) {
                        Text(item.title)
                        Text(item.subtitle)
                        Button("jump to", action: {
                            mapViewModel.updateUserRegion(mapViewModel.coordToLoc(coord: item.center))
                            viewSearchModel.clearSearch()
                            isShowingSearch.toggle()
                        })
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding([.horizontal, .top])
            .ignoresSafeArea(edges: .bottom)
            .presentationDetents([.medium])
        }
    }
}

//struct for plus and find user location buttons
struct LowerButtons: View {
    @Binding var isShowingOverlay: Bool
    @ObservedObject var mapViewModel: MapViewModel
    @State private var showLocationPrompt = false
    @State private var title: String = ""
    @State private var description: String = ""
    //@ObservedObject var speechRecognizer = SpeechToText()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecognizerActive = false
    
    
    
    var isFormValid: Bool {
        return title.count >= 5 && description.count >= 5
    }
    
    var body: some View {
        HStack() {
            //find user location button functionality
            if !isShowingOverlay {
                Button(action: {
                    mapViewModel.centerMapOnUserLocation()
                }) {
                    Image(systemName: "location.north.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 32, height: 32).padding()
                }
                Spacer()
                //add point of interest button
                Button(action: {
                    showLocationPrompt.toggle()
                }) {
                    Image(systemName: "plus").font(.system(size: 30))
                        .frame(width: 85, height: 85)
                        .foregroundColor(.black)
                        .background(.white)
                        .clipShape(Circle())
                        .shadow(color: .black, radius: 4, x: 0, y: 3)
                }
                .sheet(isPresented: $showLocationPrompt) {
                    //add point of interest button menu
                    //NSLocalizedString used to add localization for text
                    ScrollView {
                        VStack {
                            PlaceholderableTextField(text: $title, speechRecognizer: speechRecognizer, placeholder: NSLocalizedString("Enter title with at least 5 characters", comment: ""), axis: Axis.vertical, maxCharacterCount: 25, isSpeechRecognitionActive: $isRecognizerActive)
                            PlaceholderableTextField(text: $description, speechRecognizer: speechRecognizer, placeholder: NSLocalizedString("Description with at least 5 characters", comment:""), axis: Axis.vertical, maxCharacterCount: 100, isSpeechRecognitionActive: $isRecognizerActive)
                            Button("Save") {
                                showLocationPrompt = false
                                mapViewModel.createMapMarker(title: title, description: description)
                                title = ""
                                description = ""
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, isRecognizerActive ? 0 : 5)
                            .disabled(!isFormValid)
                        }
                        .padding()
                    }
                    .onDisappear {
                        isRecognizerActive = false
                    }
                    .presentationDetents([.height(210)])
                }
                .padding()
            }
        }
    }
}

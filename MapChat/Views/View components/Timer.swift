//
//  Timer.swift
//  MapChat
//
//  Created by iosdev on 4.12.2023.
//

import SwiftUI

struct TimerView: View {
    @Binding var isListening: Bool
    @State var counter: Int = 0
    var countTo: Int = 60
    var width: CGFloat = 250
    var height: CGFloat = 250
    
    var body: some View {
        if isListening {
        VStack{
            ZStack{
                ProgressTrack(height: height, width: width)
                ProgressBar(counter: counter, countTo: countTo, height: height, width: width)
                Clock(counter: counter, countTo: countTo)
            }
        }
        .onReceive(timer) { time in
            updateCounter()
        }
    }
    }
    private func updateCounter() {
            guard isListening else { return }
            guard counter < countTo else {
                isListening = false
                return
            }
            counter += 1
        }
}

let timer = Timer
    .publish(every: 1, on: .main, in: .common)
    .autoconnect()

struct Clock: View {
    var counter: Int
    var countTo: Int
    
    var body: some View {
        VStack {
            Text(counterToMinutes())
                .font(.custom("Avenir Next", size: 60))
                .fontWeight(.black)
        }
    }
    
    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
}

struct ProgressTrack: View {
    var height: CGFloat
    var width: CGFloat
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: width, height: height)
            .overlay(
                Circle().stroke(.black, lineWidth: 15)
            )
    }
}

struct ProgressBar: View {
    var counter: Int
    var countTo: Int
    var height: CGFloat
    var width: CGFloat
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: width, height: height)
            .overlay(
                Circle().trim(from:0, to: progress())
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round,
                            lineJoin:.round
                        )
                    )
                    .foregroundColor(
                        (completed() ? .green : .orange)
                    )
                    .animation(.easeInOut, value: 0.2)
            )
    }
    
    func completed() -> Bool {
        return progress() == 1
    }
    
    func progress() -> CGFloat {
        return (CGFloat(counter) / CGFloat(countTo))
    }
}

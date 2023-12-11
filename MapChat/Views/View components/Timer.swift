import SwiftUI
import Combine

struct TimerView: View {
    @Binding var isListening: Bool
    @Binding var isSpeechRecognitionActive: Bool
    @State var counter: Int = 0
    var countTo: Int = 60
    var width: CGFloat = 200
    var height: CGFloat = 20
    
    var body: some View {
        if isListening {
            VStack {
                ProgressBar(counter: counter, countTo: countTo, width: width, height: height)
                Clock(counter: counter, countTo: countTo)
            }
            .onReceive(timer) { _ in
                updateCounter()
            }
        }
    }
    
    private func updateCounter() {
        guard isListening else { return }
        guard counter < countTo else {
            isListening = false
            isSpeechRecognitionActive = false
            counter = 0
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
                .font(.custom("Avenir Next", size: 20))
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

struct ProgressBar: View {
    var counter: Int
    var countTo: Int
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: height)
                    .opacity(0.3)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(width: progressWidth(geometryWidth: geometry.size.width), height: height)
                    .foregroundColor(completed() ? .green : .orange)
                    .animation(.easeInOut, value: 1)
            }
        }
        .frame(width: width, height: height)
    }
    
    func completed() -> Bool {
        return progress() == 1
    }
    
    func progress() -> CGFloat {
        return CGFloat(counter) / CGFloat(countTo)
    }
    
    func progressWidth(geometryWidth: CGFloat) -> CGFloat {
        let totalProgress = progress() * geometryWidth
        return min(totalProgress, geometryWidth)
    }
}

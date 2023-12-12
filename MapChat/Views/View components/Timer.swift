import SwiftUI
import Combine

//Timer that counts up to minute
struct TimerView: View {
    @Binding var isListening: Bool
    @Binding var isSpeechRecognitionActive: Bool
    @State var counter: Int = 0
    var countTo: Int = 60
    var width: CGFloat = 200
    var height: CGFloat = 15
    
    var body: some View {
        if isListening {
            HStack {
                Clock(counter: counter, countTo: countTo)
                ProgressBar(counter: counter, countTo: countTo, width: width, height: height)
            }
            .frame(height: 15)
            .padding(.trailing, 35)
            .onReceive(timer) { _ in
                updateCounter()
            }
            .onChange(of: isSpeechRecognitionActive) {_ in
                    counter = 0
            }
        }
    }
    //Updates the counter by 1
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

// Timer in letters
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
    
    // Converts counter value to a string in minutes and seconds
    func counterToMinutes() -> String {
        let currentTime = countTo - counter
        let seconds = currentTime % 60
        let minutes = Int(currentTime / 60)
        
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
}
// View to display progress in a horizontal bar
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
    
    // Checks if progress is completed
    func completed() -> Bool {
        return progress() == 1
    }
    
    // Calculates the current progress value
    func progress() -> CGFloat {
        return CGFloat(counter) / CGFloat(countTo)
    }
    
    // Calculates the width of the progress bar based on its completion
    func progressWidth(geometryWidth: CGFloat) -> CGFloat {
        let totalProgress = progress() * geometryWidth
        return min(totalProgress, geometryWidth)
    }
}

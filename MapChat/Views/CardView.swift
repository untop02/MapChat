/*
 See LICENSE folder for this sample’s licensing information.
 */

import SwiftUI

struct CardView: View {
    let location: LocationList
    var body: some View {
        VStack(alignment: .leading) {
            Text(location.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                Label("\(location.attendees.count)", systemImage: "person.3")
                    .accessibilityLabel("\(location.attendees.count) attendees")
                Spacer()
                Label("\(location.lengthInMinutes)", systemImage: "clock")
                    .accessibilityLabel("\(location.lengthInMinutes) minute meeting")
            }
            .font(.caption)
        }
        
        .padding()
        .foregroundColor(location.theme.accentColor)
    }
}

struct CardView_Previews: PreviewProvider {
    static var location = LocationList.sampleData[0]
    static var previews: some View {
        CardView(location: location)
    }
}

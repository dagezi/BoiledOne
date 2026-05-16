import SwiftUI

struct ContentView: View {
    @State private var testText: String = "You can test here!"

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TextEditor(text: $testText)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

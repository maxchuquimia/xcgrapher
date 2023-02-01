//
//  ContentView.swift
//  Project1
//
//  Created by Max Chuquimia on 1/2/2023.
//

import SwiftUI
import CoreMIDI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

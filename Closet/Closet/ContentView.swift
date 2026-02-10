//
//  ContentView.swift
//  Closet
//
//  Created by Nitharsan on 10/02/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Image("Zambito")
                .resizable()
                .scaledToFit()
            
            Text ("Hello, world!")
            Text("Hello, world!")
            Text("Zambito")
            Text("Ciao, Nitharsan")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//
//  ContentView.swift
//  Closet
//
//  Created by Nitharsan on 10/02/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            
            VStack {
                Image("LogoApp")
                    .resizable()
                    .scaledToFit()
                
                Text ("Closet")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundColor(.white)
                    .padding(19)
                
            }
            .padding(.bottom, 120)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Espande l'HStack a tutto schermo
            .background(Color.black)
            .ignoresSafeArea()
            
        
        }
        
    }
}

#Preview {
    ContentView()
}

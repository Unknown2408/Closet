//
//  ClosetApp.swift
//  Closet
//
//  Created by Nitharsan on 10/02/26.
//

import SwiftUI

@main
struct ClosetApp: App {
    
    @State private var mostraFaseLogin: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if mostraFaseLogin{
                LoginView()
            } else{
                ContentView()
                    .onAppear{
                        DispatchQueue.main.asyncAfter(deadline: .now()+4.0){
                            withAnimation{
                                mostraFaseLogin = true
                            }
                        }
                    }
            }
            
            
            ContentView()
        }
    }
}

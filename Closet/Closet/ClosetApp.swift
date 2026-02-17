//
//  ClosetApp.swift
//  Closet
//
//  Created by Nitharsan on 10/02/26.
//

import SwiftUI

@main



struct ClosetApp: App {
    @State private var splashFinita: Bool = false
    @State private var loginEffettuato: Bool = false
    @State private var nomeUtente: String = ""

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea()
                if !splashFinita {
                        VStack(spacing: 40) {
                            Image("LogoApp")
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .frame(width: 350, height: 250)
                            
                            
                            Spacer()
                                .frame(height:220)
                        }
                        .padding(.top, 100)
                        .transition(.opacity)
                }else if !loginEffettuato {
                    LoginView(loginEffettuato: $loginEffettuato, nome: $nomeUtente)
                        .transition(.opacity)
                }else {
                    HomeView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 1.2), value: splashFinita)
            .animation(.easeInOut(duration: 1.2), value: loginEffettuato)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    splashFinita = true
                }
            }
        }
    }
}

//
//  SignInWithApple_GoogleApp.swift
//  SignInWithApple-Google
//
//  Created by darktech4 on 30/05/2024.
//

import SwiftUI
import Firebase

@main
struct SignInWithApple_GoogleApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

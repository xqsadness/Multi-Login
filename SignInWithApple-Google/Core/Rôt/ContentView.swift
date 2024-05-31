//
//  ContentView.swift
//  SignInWithApple-Google
//
//  Created by darktech4 on 30/05/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("log_status") private var logStatus: Bool = false
    
    var body: some View {
        if logStatus{
            HomeView()
        }else{
            SignInWithApple()
        }
    }
}

#Preview {
    ContentView()
}

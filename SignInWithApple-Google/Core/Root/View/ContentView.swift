//
//  ContentView.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 30/05/2024.
//

import SwiftUI
import SwiftData
import GoogleSignIn

struct ContentView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        VStack{
            if viewModel.userSession != nil{
                HomeView()
            }else{
                MultiLoginView()
            }
        }
        .onOpenURL { url in
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

#Preview {
    ContentView()
}

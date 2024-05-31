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
    
    @AppStorage("log_status") private var logStatus: Bool = false
    
    var body: some View {
        VStack{
            if logStatus{
                HomeView()
            }else{
                NavigationStack{
                    List{
                        NavigationLink("Apple sign in"){ SignInWithApple().navigationBarBackButtonHidden(true) }
                        NavigationLink("Multi Login"){ MultiLoginView().navigationBarBackButtonHidden(true) }
                    }
                }
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

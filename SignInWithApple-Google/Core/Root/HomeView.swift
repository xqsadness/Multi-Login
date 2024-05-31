//
//  HomeView.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 30/05/2024.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct HomeView: View {
    
    @AppStorage("log_status") private var logStatus: Bool = false

    var body: some View {
        NavigationStack{
            Button{
                try? Auth.auth().signOut()
                GIDSignIn.sharedInstance.signOut()
                withAnimation(.easeInOut){
                    logStatus = false
                }
            }label: {
                Text("Logout")
                
            }
            .navigationTitle("Home view")
        }
    }
}

#Preview {
    HomeView()
}

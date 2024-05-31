//
//  HomeView.swift
//  SignInWithApple-Google
//
//  Created by darktech4 on 30/05/2024.
//

import SwiftUI
import Firebase

struct HomeView: View {
    
    @AppStorage("log_status") private var logStatus: Bool = false

    var body: some View {
        NavigationStack{
            Button{
                try? Auth.auth().signOut()
                logStatus = false
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

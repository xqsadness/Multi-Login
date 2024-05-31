//
//  HomeView.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 30/05/2024.
//

import SwiftUI
import Firebase
import Combine

struct HomeView: View {
    
    // This is just an example. Modify this according to your logic.
    @State private var user: FirebaseAuth.User?
    
    var body: some View {
        NavigationStack{
            
            VStack(spacing: 12){
                if let user = user {
                    // You might want to fetch user's profile image URL or other information here
                    if let photoURL = user.photoURL {
                        AsyncImage(url: photoURL)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    }
                    
                    Text("Email: \(user.email ?? "Not found")")
                    
                    Text("Phone number: \(user.phoneNumber ?? "Not found")")
                    
                    Text("Display Name: \(user.displayName ?? "Not found")")
                }
                
                Button{
                    withAnimation {
                        AuthService.shared.signOut()
                    }
                }label: {
                    Text("Logout")
                        .foregroundStyle(.blue)
                }
                .padding(.top, 20)
            }
            .foregroundStyle(.primary)
            .navigationTitle("Home view")
        }
        .onAppear{
            // This is just an example. Modify this according to your logic.
            self.user = Auth.auth().currentUser
        }
    }
}

#Preview {
    HomeView()
}

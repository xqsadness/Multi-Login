//
//  LoginView.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 30/05/2024.
//

import SwiftUI
import Firebase
import AuthenticationServices
import CryptoKit

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    //View props
    @State private var errorMessage: String = ""
    @State private var showAlert: Bool = false
    @State private var isLoading: Bool = false
    @State private var nonce: String?
    @Environment(\.colorScheme) private var colorScheme
    //User log status
    @AppStorage("log_status") private var logStatus: Bool = false
    var body: some View {
        ZStack(alignment: .bottom){
            GeometryReader{
                let size = $0.size
                
                Image(.BG)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .offset(y: -60)
                    .frame(width: size.width, height: size.height)
                
            }
            //Gradient masking at bottom
            .mask {
                Rectangle()
                    .fill(.linearGradient(
                        colors: [
                            .white,
                            .white,
                            .white,
                            .white,
                            .white.opacity(0.9),
                            .white.opacity(0.6),
                            .white.opacity(0.2),
                            .clear,
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
            }
            .ignoresSafeArea()
            
            //Sign in button
            VStack{
                Text("Sign in to start your \nlearning expreience")
                    .font(.title).bold()
                
                SignInWithAppleButton(.signIn) { rq in
                    let nonce = randomNonceString()
                    self.nonce = nonce
                    //Your prefrences
                    rq.requestedScopes = [.email, .fullName]
                    rq.nonce = sha256(nonce)
                } onCompletion: { rs in
                    switch rs{
                    case .success(let author):
                        loginWithFirebase(author)
                    case .failure(let err):
                        showError(err.localizedDescription)
                    }
                }
                .overlay{
                    ZStack{
                        Capsule()
                        
                        HStack{
                            Image(systemName: "appleLogo")
                            
                            Text("Sign in with apple")
                        }
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                    }
                    .allowsHitTesting(false)
                }
                .frame(height: 45)
                .clipShape(.capsule)
                .padding(.top, 10)
                
                Button{
                    dismiss()
                }label: {
                    Text("Other Sign in Options")
                        .foregroundStyle(Color.primary)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .contentShape(.capsule)
                        .background(){
                            Capsule()
                                .stroke(Color.primary, lineWidth: 0.5)
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .alert(errorMessage, isPresented: $showAlert) { }
        .overlay {
            if isLoading{
                LoadingScreen()
            }
        }
    }
    
    //Loading screen
    @ViewBuilder
    func LoadingScreen() -> some View{
        ZStack{
            Rectangle()
                .fill(.ultraThinMaterial)
            
            ProgressView()
                .frame(width: 45, height: 45)
                .background(.background, in: .rect(cornerRadius: 5))
        }
    }
    
    //Pressing error's
    func showError(_ message: String){
        errorMessage = message
        showAlert.toggle()
        isLoading = false
    }
    
    //Login with firebase
    func loginWithFirebase(_ authorization: ASAuthorization){
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            //Showing loading screen until login completion with firebase
            isLoading = true
            
            guard let nonce else {
                showError("Cannot process your request.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                showError("Cannot process your request.")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                showError("Cannot process your request.")
                return
            }
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: nonce,
                                                           fullName: appleIDCredential.fullName)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    showError(error.localizedDescription)
                }
                // User is signed in to Firebase with Apple.
                //Pushing user to home view
                logStatus = true
                isLoading = false
                
                print(authResult)
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError(
                "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            )
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

#Preview {
    SignInWithApple()
}

//
//  AuthService.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 31/05/2024.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthService {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var isLoading: Bool = false
    
    static var shared = AuthService()
    
    init(){
        self.userSession = Auth.auth().currentUser
    }
    
    // MARK: Phone otp sign in
    @MainActor
    func verifyCode(CLIENT_CODE: String, otpCode: String) async throws{
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
        
        let result = try await Auth.auth().signIn(with: credential)
        
        //Mark: user logged in succesfully
        print("Success phone!")
        self.userSession = result.user
    }
    
    // MARK: Apple sign in
    @MainActor
    func appleAuthenticate(_ credential: ASAuthorizationAppleIDCredential,nonce: String ,completion: @escaping () -> Void){
        guard let appleIDToken = credential.identityToken else {
            print("Cannot process your request.")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Cannot process your request.")
            return
        }
        // Initialize a Firebase credential, including the user's full name.
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: credential.fullName)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error {
                print(error.localizedDescription)
            }
            // User is signed in to Firebase with Apple.
            self.userSession = authResult?.user
            withAnimation(.easeInOut){
                completion()
            }
        }
    }
    
    // MARK: Google sign in
    @MainActor
    func logGoogleUser(user: GIDGoogleUser) async throws{
        guard let idToken = user.idToken?.tokenString else { return }
        let accesToken = user.accessToken.tokenString
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accesToken)
        
        let result = try await Auth.auth().signIn(with: credential)
        print("Success google")
        self.userSession = result.user
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            self.userSession = nil
        }catch{
            print("Failed to sign out: \(error.localizedDescription)")
        }
    }
}

//Apple sign in helper
func randomNonceString(length: Int = 32) -> String {
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

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
    }.joined()
    
    return hashString
}

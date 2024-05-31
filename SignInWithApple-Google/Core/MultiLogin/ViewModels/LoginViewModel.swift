//
//  LoginViewModel.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 31/05/2024.
//

import SwiftUI
import Firebase
import AuthenticationServices
import CryptoKit
import GoogleSignIn

class LoginViewModel: ObservableObject {
    
    //View props
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    //Error props
    @Published var showError:Bool = false
    @Published var errorMessage: String = ""
    
    //Apple log status
    @AppStorage("log_status") private var logStatus: Bool = false
    
    //Apple sign in prop
    @Published var nonce: String = ""
    
    //Firebase api's
    func getOTPCode(){
        UIApplication.shared.closeKeyboard()
        Task{
            do{
                //Mark: Disbale it when testing with real device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run {
                    CLIENT_CODE = code
                    //Mark enabling otp field when it success
                    withAnimation(.easeInOut){ showOTPField = true }
                }
                
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode(){
        UIApplication.shared.closeKeyboard()
        Task{
            do{
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                try await Auth.auth().signIn(with: credential)
                
                //Mark: user logged in succesfully
                print("Success !")
                await MainActor.run {
                    withAnimation(.easeInOut){
                        logStatus = true
                    }
                }
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    //handling Error
    func handleError(error: Error) async{
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
        }
    }
    
    //Apple sign in
    func appleAuthenticate(_ credential: ASAuthorizationAppleIDCredential){
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
        Auth.auth().signIn(with: credential) { [self] (authResult, error) in
            if let error {
                print(error.localizedDescription)
            }
            // User is signed in to Firebase with Apple.
            dump(authResult)
            withAnimation(.easeInOut){
                logStatus = true
            }
        }
    }
    
    //Mark: Logging google user info firebase
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            do{
                guard let idToken = user.idToken?.tokenString else { return }
                let accesToken = user.accessToken.tokenString
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accesToken)
                
                try await Auth.auth().signIn(with: credential)
                print("Success google")
                await MainActor.run {
                    withAnimation(.easeInOut){
                        logStatus = true
                    }
                }
            }catch{
                await handleError(error: error)
            }
        }
    }
}

//Extension
extension UIApplication{
    func closeKeyboard(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func rootController() -> UIViewController{
        guard let window = connectedScenes.first as? UIWindowScene else { return .init() }
        guard let viewController = window.windows.last?.rootViewController else { return .init() }
        
        return viewController
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

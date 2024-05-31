//
//  LoginViewModel.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 31/05/2024.
//

import SwiftUI
import Firebase
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: ObservableObject {
    
    // MARK: View props
    @Published var mobileNo: String = ""
    @Published var otpCode: String = ""
    @Published var isLoading: Bool = false
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    // MARK: Error props
    @Published var showError:Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: Apple sign in prop
    @Published var nonce: String = ""
    
    // MARK: Firebase api's
    @MainActor
    func getOTPCode(){
        UIApplication.shared.closeKeyboard()
        Task{
            do{
                // MARK: Disbale it when testing with real device
                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run {
                    CLIENT_CODE = code
                    // MARK: enabling otp field when it success
                    withAnimation(.easeInOut){ showOTPField = true }
                }
                
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    // MARK: Phone otp sign in
    func verifyOTPCode(){
        isLoading = true
        UIApplication.shared.closeKeyboard()
        Task{
            do{
                try await AuthService.shared.verifyCode(CLIENT_CODE: CLIENT_CODE, otpCode: otpCode)
                await MainActor.run {
                    withAnimation(.easeInOut){
                        isLoading = false
                    }
                }
            }catch{
                await handleError(error: error)
            }
        }
    }
    
    // MARK: handling Error
    func handleError(error: Error) async{
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError.toggle()
            isLoading = false
        }
    }
    
    // MARK: Apple sign in
    func appleAuthenticate(_ credential: ASAuthorizationAppleIDCredential){
        isLoading = true
        AuthService.shared.appleAuthenticate(credential, nonce: nonce) { [self] in
            withAnimation(.easeInOut){
                isLoading = false
            }
        }
    }
    
    // MARK: Logging google user info firebase
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            do{
                isLoading = true
                try await AuthService.shared.logGoogleUser(user: user)
                await MainActor.run {
                    withAnimation(.easeInOut){
                        isLoading = false
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

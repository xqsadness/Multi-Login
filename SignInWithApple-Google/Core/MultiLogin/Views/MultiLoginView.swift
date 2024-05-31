//
//  MultiLoginView.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 31/05/2024.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct MultiLoginView: View {
    
    @StateObject private var vm = LoginViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(.vertical){
            VStack(alignment: .leading, spacing: 15){
                Image(systemName: "triangle")
                    .font(.system(size: 38))
                    .foregroundStyle(.indigo)
                
                (Text("Welcome,")
                    .foregroundStyle(.black) +
                 
                 Text("\nLogin to continue")
                    .foregroundStyle(.gray)
                )
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(10)
                .padding(.top, 20)
                .padding(.trailing, 15)
                .onTapGesture {
                    dismiss()
                }
                
                //Custom textField
                CustomTextField(hint: "+84 123456789", text: $vm.mobileNo)
                    .disabled(vm.showOTPField)
                    .opacity(vm.showOTPField ? 0.4 : 1)
                    .overlay(alignment: .trailing){
                        Button("Change"){
                            withAnimation(.easeInOut){
                                vm.showOTPField = false
                                vm.otpCode = ""
                                vm.CLIENT_CODE = ""
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.indigo)
                        .opacity(vm.showOTPField ? 1 : 0)
                        .padding(.trailing, 15)
                    }
                    .padding(.top, 50)
                
                CustomTextField(hint: "OTP Code", text: $vm.otpCode)
                    .disabled(!vm.showOTPField)
                    .opacity(!vm.showOTPField ? 0.4 : 1)
                    .padding(.top, 20)
                
                Button{
                    vm.showOTPField ? vm.verifyOTPCode() : vm.getOTPCode()
                }label: {
                    HStack(spacing: 15){
                        Text(vm.showOTPField ? "Verify code" : "Get code")
                            .fontWeight(.semibold)
                            .contentTransition(.identity)
                        
                        Image(systemName: "line.diagonal.arrow")
                            .font(.title3)
                            .rotationEffect(.init(degrees: 45))
                    }
                    .foregroundStyle(.black)
                    .padding(.horizontal, 25)
                    .padding(.vertical)
                    .background{
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.black.opacity(0.05))
                    }
                }
                .padding(.top, 20)
                
                Text("(OR)")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    .padding(.leading, -60)
                    .padding(.horizontal)
                
                HStack(spacing: 8){
                    // MARK: Cutom apple sign in button
                    CustomButton()
                        .overlay {
                            SignInWithAppleButton(.signIn) { rq in
                                let nonce = randomNonceString()
                                vm.nonce = nonce
                                //Your prefrences
                                rq.requestedScopes = [.email, .fullName]
                                rq.nonce = sha256(vm.nonce)
                            } onCompletion: { rs in
                                switch rs{
                                case .success(let author):
                                    guard let credential = author.credential as? ASAuthorizationAppleIDCredential else{
                                        print("Error with firebase")
                                        return
                                    }
                                    vm.appleAuthenticate(credential)
                                case .failure(let err):
                                    print(err.localizedDescription)
                                }
                            }
                            .signInWithAppleButtonStyle(.white)
                            .frame(height: 55)
                            .blendMode(.overlay)
                        }
                        .clipped()
                    
                    // MARK: Cutom google sign in button
                    CustomButton(isGoogle: true)
                        .overlay {
                            GoogleSignInButton {
                                GIDSignIn.sharedInstance.signIn(withPresenting: UIApplication.shared.rootController()){ user, err in
                                    if let err = err{
                                        print(err.localizedDescription)
                                        return
                                    }
                                    
                                    if let user = user?.user{
                                        vm.logGoogleUser(user: user)
                                    }
                                }
                            }
                            .blendMode(.overlay)
                        }
                        .clipped()
                }
                .padding(.leading, -60)
                .frame(maxWidth: .infinity)
            }
            .padding(.leading, 60)
            .padding(.vertical, 15)
        }
        .scrollIndicators(.hidden)
        .alert(vm.errorMessage, isPresented: $vm.showError) {}
    }
    
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false) -> some View{
        HStack{
            Image(systemName: isGoogle ? "g.circle" : "apple.logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
            
            Text("\(isGoogle ? "Google" : "Apple") sign in")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 15)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
        }
    }
}

#Preview {
    MultiLoginView()
}

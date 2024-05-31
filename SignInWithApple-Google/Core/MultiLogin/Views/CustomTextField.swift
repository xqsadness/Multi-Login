//
//  CustomTextField.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 31/05/2024.
//

import SwiftUI

struct CustomTextField: View {
    
    var hint: String
    @Binding var text: String
    // view props
    @FocusState var isEnabled: Bool
    var contenType: UITextContentType = .telephoneNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            TextField(hint, text: $text)
                .keyboardType(.numberPad)
                .textContentType(contenType)
                .focused($isEnabled)
            
            ZStack(alignment: .leading){
                Rectangle()
                    .fill(.black.opacity(0.2))
                
                Rectangle()
                    .fill(.black)
                    .frame(width: isEnabled ? nil : 0, alignment: .leading)
                    .animation(.easeInOut(duration: 0.3), value: isEnabled)
            }
            .frame(height: 2)
        }
    }
}

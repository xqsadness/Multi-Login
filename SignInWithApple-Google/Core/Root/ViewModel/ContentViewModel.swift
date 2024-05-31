//
//  ContentViewModel.swift
//  SignInWithApple-Google
//
//  Created by xqsadness on 31/05/2024.
//

import SwiftUI
import Firebase
import Combine

class ContentViewModel: ObservableObject{
    
    @Published var userSession: FirebaseAuth.User?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        setupSubcribers()
    }
    
    private func setupSubcribers(){
        AuthService.shared.$userSession
            .sink{ [weak self] userSessionFromAuthService in
                self?.userSession = userSessionFromAuthService
            }
            .store(in: &cancellables)
    }
}

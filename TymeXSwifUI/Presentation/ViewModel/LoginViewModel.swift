//
//  LoginViewModel.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 11/3/25.
//
import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var username: String = "khanhtoan@gmail.com"
    @Published var password: String = "1234567890"
    @Published var isLoginEnabled: Bool = false
    @Published var passwordStrength: Float = 0.0
    @Published var showError: Bool = false
    @Published var successLogin: Bool = false
    
    var validationSubject = PassthroughSubject<(String, String), Never>()
    
    init() {
        observeValidation()
    }
    
    func observeValidation() {
        validationSubject
            .map { [weak self] username, password in
                guard let self = self else { return false }
                return self.isValidEmail(username) && self.passwordStrength >= 0.5
            }
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoginEnabled)
        
        $password
            .map { self.calculatePasswordStrength($0) }
            .receive(on: DispatchQueue.main)
            .assign(to: &$passwordStrength)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func calculatePasswordStrength(_ password: String) -> Float {
        switch password.count {
        case 0...3: return 0.1
        case 4...6: return 0.4
        case 7...9: return 0.7
        default: return 1.0
        }
    }
    
    func attemptLogin() {
        if isLoginEnabled {
            successLogin = true
        } else {
            showError = true
        }
    }
}

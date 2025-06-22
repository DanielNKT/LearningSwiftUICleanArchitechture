//
//  LoginView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 11/3/25.
//
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var viewModel: LoginViewModel
    @State private var shakeOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Label(LocalizableKey.login, systemImage: "person.circle")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            TextField(LocalizableKey.email, text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField(LocalizableKey.password, text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ProgressView(value: viewModel.passwordStrength)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: 200)
                .tint(viewModel.passwordStrength > 0.7 ? .green : .red)
            
            Button {
                viewModel.attemptLogin()
                if !viewModel.successLogin {
                    shakeButton()
                } else {
                    appState.isLoggedIn = true
                }
            } label: {
                Text(LocalizableKey.login)
                    .foregroundColor(.white) // Text color
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 3, x: 2, y: 2)
            }
            .disabled(!viewModel.isLoginEnabled)
            .opacity(viewModel.isLoginEnabled ? 1.0 : 0.5)
            .offset(x: shakeOffset)
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 48, maxHeight: 48)
            .foregroundColor(.white) // Change text color
            .background(Color.blue)
            .cornerRadius(8)
            .shadow(color: .gray, radius: 3, x: 2, y: 2)
            .animation(.default, value: shakeOffset) // ✅ Use SwiftUI animation
            
            if viewModel.showError {
                Text("Invalid email or password")
                    .foregroundColor(.red)
                    .font(.caption)
                    .transition(.opacity)
            }
        }
        .padding()
    }
    
    private func shakeButton() {
        withAnimation {
            shakeOffset = 10
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                shakeOffset = -10
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                shakeOffset = 0
            }
        }
    }
}



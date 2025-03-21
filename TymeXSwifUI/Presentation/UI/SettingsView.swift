//
//  SettingsView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 14/3/25.
//
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var coordinator: AppCoordinator
    
    @State private var message: String = ""
    @State private var isShowingPopup: Bool = false
    
    var body: some View {
        ZStack {
            List {
                // Row 1: Display message
                Text(message)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Row 2: Logout button
                Button("Logout") {
                    coordinator.resetToLogin()
                    appState.isLoggedIn = false
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Row 3: Go to profile
                Button("Go to profile") {
                    isShowingPopup = true
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            // Make the list plain (optional)
            .listStyle(.plain)
            .allowsHitTesting(!isShowingPopup) 
            
            if isShowingPopup {
                PopupView(isShowing: $isShowingPopup) { newMessage in
                    self.message = newMessage
                }
            }
            
        }
    }
}

struct PopupView: View {
    @Binding var isShowing: Bool
    @State private var tempMessage: String = ""
    var onSave: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter Text")
                .font(.headline)
            
            TextField("Type something...", text: $tempMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Submit") {
                onSave(tempMessage)
                isShowing = false
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
    }
}

struct ChildView: View {
    @State private var tempMessage: String = ""
    var onSave: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            Text("You have entered: \(tempMessage)")
            
            TextField("Enter message", text: $tempMessage)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save & Dismiss") {
                onSave(tempMessage) // Send data back
                dismiss() // Close the sheet
            }
        }
        .padding()
    }
}

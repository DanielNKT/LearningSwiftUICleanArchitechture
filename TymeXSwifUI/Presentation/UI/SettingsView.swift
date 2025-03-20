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
    
    @State private var message: String = "Hello"
    @State private var isSheetPresented: Bool = false
    
    var body: some View {
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
                isSheetPresented = true
            }
            .sheet(isPresented: $isSheetPresented) {
                ChildView { newMessage in
                    message = newMessage
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        // Make the list plain (optional)
        .listStyle(.plain)
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


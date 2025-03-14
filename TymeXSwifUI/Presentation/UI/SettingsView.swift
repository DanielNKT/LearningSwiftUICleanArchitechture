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
    var body: some View {
        Button("Logout") {
            coordinator.resetToLogin()
            appState.isLoggedIn = false
        }
    }
}

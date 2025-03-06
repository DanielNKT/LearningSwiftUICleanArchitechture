//
//  TymeXSwifUIApp.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 3/3/25.
//

import SwiftUI

@main
struct TymeXSwifUIApp: App {
    var body: some Scene {
        WindowGroup {
            let userRepository = UserRepository()
            let service = UserService(userRepository: userRepository)
            let viewModel = HomeViewModel(service: service)
            Home(viewModel: viewModel)
        }
    }
}

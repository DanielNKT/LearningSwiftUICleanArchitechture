//
//  ContentView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 3/3/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    let userRepository = UserRepository()
    let service = UserService(userRepository: userRepository)
    let viewModel = HomeViewModel(service: service)
    Home(viewModel: viewModel)
}

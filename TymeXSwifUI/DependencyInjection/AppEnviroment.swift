//
//  AppEnviroment.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import Foundation

struct AppEnviroment {
    static let baseURL: String = "https://api.github.com"
}

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

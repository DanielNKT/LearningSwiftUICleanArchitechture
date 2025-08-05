//
//  AppEnviroment.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import Foundation

struct AppEnviroment {
    static let baseURL: String = Bundle.main.infoDictionary?["BaseURL"] as? String ?? ""
    static let isAlpha = true
}

class AppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

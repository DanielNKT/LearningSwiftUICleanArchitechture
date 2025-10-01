//
//  URLSessionExtention.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 7/3/25.
//
import Foundation

extension URLRequest {
    mutating func addParameters(_ parameters: Parameters?, method: HTTPMethod) {
        guard let parameters, let dicParams = parameters.toDictionary() else { return }
        if method == HTTPMethod.GET {
            guard var urlComponents = URLComponents(url: self.url!, resolvingAgainstBaseURL: false) else { return }
            urlComponents.queryItems = dicParams.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            self.url = urlComponents.url
        } else {
            self.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            self.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
    }
}

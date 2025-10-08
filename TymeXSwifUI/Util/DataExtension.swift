//
//  DataExtension.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 1/10/25.
//
import Foundation

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

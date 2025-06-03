//
//  ListBooksViewModel.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 23/5/25.
//
import SwiftUI
import Combine

class ListBooksViewModel: ObservableObject {
    @Published var activeID: String?
    @Published var scrollPosition = ScrollPosition(idType: String.self)
    @Published var isAnyBookCardScrolled = false
    
    init() {
        print("[DEBUG] - ListBooksViewModel init")
    }
}


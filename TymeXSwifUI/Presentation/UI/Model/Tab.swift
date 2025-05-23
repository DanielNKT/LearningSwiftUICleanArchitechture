//
//  Tab.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 23/5/25.
//

import SwiftUI

enum Tab: String, CaseIterable {
    case users
    case books
    
    var systemImage: String {
        switch self {
            case .users:
            return "list.dash"
        case .books:
            return "book.fill"
        }
    }
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}

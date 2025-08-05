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

enum ProfileTab: String, CaseIterable, Identifiable {
    case posts = "Posts"
    case reels = "Reels"
    case tags = "Tags"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .posts: return "square.grid.3x3.fill"
        case .reels: return "play.rectangle.on.rectangle.fill"
        case .tags: return "person.crop.square.fill"
        }
    }

    var title: String {
        rawValue
    }

    var tabItem: TabbarItem {
        TabbarItem(title: title, icon: icon)
    }
}

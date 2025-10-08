//
//  Chat.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 2/10/25.
//

import Foundation

struct ChatMessage: Codable, Identifiable {
    var id: String
    var text: String
    var date: Date
    var isSender: Bool
    var type: MessageType
    enum CodingKeys: String, CodingKey {
        case id, text, date, type
        case isSender = "sender"
    }
}

enum MessageType: String, Codable {
    case text
    case gallery
    case file
}

//
//  Book.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 21/5/25.
//

import SwiftUI

struct Book: Identifiable {
    var id: String = UUID().uuidString
    var title: String
    var author: String
    var rating: String
    var thumbnail: String
    var color: Color
}

let books: [Book] = [
    .init(title: "The Alchemist", author: "Paulo Coelho", rating: "4.2", thumbnail: "Book1.jpeg", color: .blue),
    .init(title: "To Kill a Mockingbird", author: "Harper Lee", rating: "4.7", thumbnail: "Book2.jpg", color: .yellow),
    .init(title: "1984", author: "George Orwell", rating: "4.3", thumbnail: "Book3.jpg", color: .red),
]

let dummyText: String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

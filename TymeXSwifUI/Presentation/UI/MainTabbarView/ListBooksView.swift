//
//  ListBooksView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 21/5/25.
//

import SwiftUI

struct ListBooksView: View {
    
    @ObservedObject var viewModel: ListBooksViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 4) {
                        ForEach(books) { book in
                            BookCardView(book: book, size: geometry.size) { isScrolled in
                                viewModel.isAnyBookCardScrolled = isScrolled
                            }
                            .frame(width: geometry.size.width - 30)
                            .zIndex(viewModel.activeID == book.id ? 1000 : 1)
                            .id(book.id)
                        }
                    }
                    .scrollTargetLayout()
                }
                .safeAreaPadding(15)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition($viewModel.scrollPosition)
                .scrollDisabled(viewModel.isAnyBookCardScrolled)
                .onChange(of: viewModel.scrollPosition.viewID(type: String.self)) { oldValue, newValue in
                    viewModel.activeID = newValue
                }
                .onAppear {
                    // 🔁 Scroll to saved ID when view appears
                    if let id = viewModel.activeID {
                        DispatchQueue.main.async {
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

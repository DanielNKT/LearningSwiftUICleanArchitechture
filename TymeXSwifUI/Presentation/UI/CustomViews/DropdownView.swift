//
//  DropdownView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 14/12/25.
//

import Combine
import SwiftUI

protocol DropdownItem: Hashable {
    var title: String { get }
}

struct DropdownView<Item: DropdownItem>: View {

    let title: String
    let items: [Item]

    @Binding var selectedItem: Item?
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            // Header
            Button {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(selectedItem?.title ?? title)
                        .foregroundColor(selectedItem == nil ? .gray : .primary)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4))
                )
            }

            // Dropdown list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        Button {
                            print("Tapped item:", item.title)
                            selectedItem = item
                            print("selectedItem ---- \(selectedItem)")
                            withAnimation {
                                isExpanded = false
                            }
                        } label: {
                            HStack {
                                Text(item.title)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                        }
                        .background(Color.white)

                        Divider()
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3))
                        .background(Color.white.cornerRadius(8))
                )
                .shadow(radius: 3)
            }
        }
    }
}

enum Gender: String, DropdownItem, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"

    var title: String { rawValue }
}


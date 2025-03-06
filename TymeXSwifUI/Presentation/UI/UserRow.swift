//
//  UserRow.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 4/3/25.
//
import SwiftUI

struct UserRow: View {
    let user: User
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person")
                .resizable()
                .frame(width: 80, height: 80)
                .background(Circle().fill(Color.gray))
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(user.login ?? "unknown")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Divider()
                    .padding(.leading, 8)
                    .background(.gray)
                Text(.init(user.htmlURL ?? "unknown")).underline()
                    .font(.system(size: 14, weight: .regular, design: .rounded))
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Rectangle().fill(Color.white))
        .cornerRadius(10)
        .shadow(color: .gray.opacity(0.3), radius: 3, x: 2, y: 2)
        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
    }
}

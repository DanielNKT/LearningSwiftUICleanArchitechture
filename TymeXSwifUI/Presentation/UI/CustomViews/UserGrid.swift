//
//  UserGrid.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 18/3/25.
//

import SwiftUI

struct PhotoCardView: View {
    let user: User
    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: {
            if let urlString = user.avatarURL, let url = URL(string: urlString){
                CachedAsyncImage(url: url)
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .clipped()
            } else {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .clipped()
            }
            
            VStack(alignment: .leading) {
                Text(user.login ?? "unknown")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Divider()
                    .background(.gray)
                Text(.init(user.htmlURL ?? "unknown")).underline()
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                Spacer() // To push the view on top
            }
            .padding(8)
        })
        .background(Rectangle().fill(Color.white))
        .cornerRadius(10)
        .shadow(color: .gray, radius: 3, x: 2, y: 2)
    }
}

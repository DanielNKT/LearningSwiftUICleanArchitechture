//
//  UserDetail.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 4/3/25.
//
import SwiftUI

struct UserDetail: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .background(Circle().fill(Color.gray))
                VStack(alignment: .leading) {
                    Text("Test Name")
                    Divider()
                        .padding(.leading, 8)
                        .background(.gray)
                    Text(.init("https://vnexpress.net")).underline()
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(Rectangle().fill(Color.white))
            .cornerRadius(10)
            .shadow(color: .gray.opacity(0.3), radius: 3, x: 2, y: 2)
            
            HStack(alignment: .center) {
                Spacer()
                VStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.gray))
                    Text("100+")
                    Text("Followers")
                }
                Spacer()
                VStack {
                    Image(systemName: "star.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .background(Circle().fill(Color.gray))
                    Text("10+")
                    Text("Following")
                }
                Spacer()
            }.padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Blog")
                    Text("https://vnexpress.net")
                }
                Spacer()
            }
            
            
            Spacer()
            
        }
        .padding(.top, 8)
        .padding(.leading, 24)
        .padding(.trailing, 24)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("User Detail").font(.headline)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss() // Go back
                }) {
                    Image(systemName: "arrow.left") // Custom icon
                        .font(.title)
                        .foregroundColor(.black)
                }
                
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UserDetail()
}

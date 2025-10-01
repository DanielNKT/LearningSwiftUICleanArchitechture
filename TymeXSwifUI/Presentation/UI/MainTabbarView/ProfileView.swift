//
//  ProfileView.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 5/8/25.
//
import SwiftUI

struct ProfileView: View {
    private let tabs = ["Posts", "Reels", "Tags"]

    @State private var selectedTab = "Posts"

    var body: some View {
        VStack(spacing: 0) {
            profileHeader

            stickyTabBar

            TabView(selection: $selectedTab) {
                ForEach(tabs, id: \.self) { tab in
                    ScrollableTabContent(tab: tab)
                        .tag(tab)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 12)

            Text("Username")
                .font(.headline)

            Divider()
        }
        .padding(.bottom, 8)
    }

    private var stickyTabBar: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab)
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .background(Color.white)
        .overlay(Divider(), alignment: .bottom)
    }
}

struct ScrollableTabContent: View {
    let tab: String

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(), count: 3), spacing: 2) {
                ForEach(0..<30, id: \.self) { i in
                    Rectangle()
                        .fill(colorForTab.opacity(0.6))
                        .frame(height: 120)
                        .overlay(Text("\(i)").foregroundColor(.white))
                }
            }
            .padding(.top, 2)
        }
    }

    private var colorForTab: Color {
        switch tab {
        case "Posts": return .blue
        case "Reels": return .red
        case "Tags": return .green
        default: return .gray
        }
    }
}



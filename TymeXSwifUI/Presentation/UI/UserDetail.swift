//
//  UserDetail.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 4/3/25.
//
import SwiftUI

struct UserDetail: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject private var viewModel: UserDetailViewModel
    
    init(viewModel: UserDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        Group {
            
            VStack {
                if viewModel.isLoading {
                    loadingView()
                } else if let errorMessage = viewModel.errorMessage {
                    failedView(errorMessage)
                } else {
                    Group {
                        HStack(alignment: .top) {
                            if let urlString = viewModel.user?.avatarURL, let url = URL(string: urlString){
                                CachedAsyncImage(url: url)
                                    .frame(width: 80, height: 80)
                                    .background(Circle().fill(Color.gray))
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .background(Circle().fill(Color.gray))
                                    .clipShape(Circle())
                            }
                            VStack(alignment: .leading) {
                                Text(viewModel.user?.name ?? "unknown")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                Divider()
                                    .padding(.leading, 8)
                                    .background(.gray)
                                HStack {
                                    Image(systemName: "location")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                        .background(Circle().fill(Color.clear))
                                    Text(viewModel.user?.location ?? "unknown")
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(Rectangle().fill(Color.white))
                        .cornerRadius(10)
                        .shadow(color: .gray, radius: 3, x: 2, y: 2)
                        
                        HStack(alignment: .center) {
                            Spacer()
                            VStack {
                                Image(systemName: "person.2.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .background(Circle().fill(Color.clear))
                                Text(String(format: "%d", viewModel.user?.followers ?? 0))
                                Text("Followers")
                            }
                            Spacer()
                            VStack {
                                Image(systemName: "person.crop.circle.fill.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .background(Circle().fill(Color.clear))
                                Text(String(format: "%d", viewModel.user?.following ?? 0))
                                Text("Following")
                            }
                            Spacer()
                        }.padding()
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Blog")
                                Text(.init(viewModel.user?.blog ?? "")).underline()
                            }
                            Spacer()
                        }
                        
                        
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.leading, 24)
                    .padding(.trailing, 24)
                }
                
                
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("User Detail").font(.headline)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        coordinator.pop() // Go back
                    }) {
                        Image(systemName: "arrow.left") // Custom icon
                            .font(.title)
                            .foregroundColor(.black)
                    }
                    
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if !viewModel.hasLoaded {
                    viewModel.fetchUsers()
                    viewModel.hasLoaded = true
                }
            }
        }
        
    }
}

private extension UserDetail {
    func loadingView() -> some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
    }
    
    func failedView(_ errorMessage: String) -> some View {
        ErrorView(errorMessage: errorMessage, retryAction: {
            viewModel.fetchUsers()
        })
    }
}

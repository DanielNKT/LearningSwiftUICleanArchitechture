//
//  GithubUserViewModel.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 27/5/25.
//

import Combine

class GithubUsersViewModel: ObservableObject {
    @Published var currentSegment: UserSegment = .list
}

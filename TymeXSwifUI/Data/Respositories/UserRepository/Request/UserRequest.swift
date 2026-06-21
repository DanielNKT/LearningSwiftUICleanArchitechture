//
//  UserRequest.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 6/3/25.
//
import Foundation

struct UserListRequest: Parameters {
    var per_page: Int = 20
    var since: Int = 0
}

struct UserDetailRequest: Parameters {
    var name: String?
}

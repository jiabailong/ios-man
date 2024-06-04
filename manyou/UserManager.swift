//
//  UserManager.swift
//  manyou
//
//  Created by jiabailong1 on 2024/6/3.
//

import Foundation
class UserManager: ObservableObject {
    @Published var token: String? = nil
    @Published var refresh_token: String? = nil
}

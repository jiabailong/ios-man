//
//  UserManager.swift
//  manyou
//
//  Created by jiabailong1 on 2024/6/3.
//

import Foundation
class UserManager {
    // 创建单例实例
      static let shared = UserManager()
     var token: String? = nil
     var refresh_token: String? = nil
    private init() {}

}

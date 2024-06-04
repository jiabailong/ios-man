//
//  Message.swift
//  manyou
//
//  Created by jiabailong1 on 2024/6/3.
//

import Foundation
struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool // 标识消息是否来自用户
}

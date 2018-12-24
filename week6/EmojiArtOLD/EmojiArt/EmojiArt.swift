//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Cong Doan on 12/21/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import Foundation

struct EmojiArt: Codable {
    
    let url: URL
    let emojis: [EmojiInfo]
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
    
    init?(json: Data) {
        guard let newValue = try? JSONDecoder().decode(EmojiArt.self, from: json) else { return nil }
        self = newValue
    }
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
}

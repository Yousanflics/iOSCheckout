//
//  OrderItem.swift
//  iOSCheckout
//
//  Created by yousanflics on 3/3/25.
//

import Foundation

struct OrderResponse: Decodable {
    let id: String
    let items: [OrderItem]
}

struct OrderItem: Decodable, Identifiable {
    let id = UUID()
    let itemName: String
    let displayPrice: String
    
    init(itemName: String, displayPrice: String) {
        self.itemName = itemName
        self.displayPrice = displayPrice
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case display_price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        itemName = try container.decode(String.self, forKey: .name)
        displayPrice = try container.decodeIfPresent(String.self, forKey: .display_price) ?? "Free"
    }
}

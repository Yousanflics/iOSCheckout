//
//  CheckoutService.swift
//  iOSCheckout
//
//  Created by yousanflics on 3/3/25.
//
import Foundation

//class CheckoutService {
//    private let session = LocalNetworkSession()
//
//    func fetchOrder(completion: @escaping ([OrderItem]?) -> Void) {
//        session.getOrder { data in
//            do {
//                let decoder = JSONDecoder()
//                let orderResponse = try decoder.decode(OrderResponse.self, from: data)
//                let orderItems = orderResponse.items.map {
//                    OrderItem(itemName: $0.itemName, displayPrice: $0.displayPrice)
//                }
//                
//                print("Order ID: \(orderResponse.id)")
//                print("Items: \(orderItems)")
//                completion(orderItems)
//            } catch {
//                print("Decoder error: \(error)")
//                completion(nil)
//            }
//            //print(String(data: data, encoding: .utf8)!)
//        }
//    }
//
//    func submitOrder(orderId: String) {
//        session.submitOrder(orderId: orderId) { data in
//            print(String(data: data, encoding: .utf8)!)
//        }
//    }
//}

import Foundation

class CheckoutService {
    private let session = LocalNetworkSession()

    // 使用 async/await 获取订单数据
    func fetchOrder() async throws -> [OrderItem] {
        let data = try await session.getOrder()
        let decoder = JSONDecoder()
        let orderResponse = try decoder.decode(OrderResponse.self, from: data)
        
        print("Order ID: \(orderResponse.id)")
        print("Items: \(orderResponse.items)")

        return orderResponse.items.map {
            OrderItem(itemName: $0.itemName, displayPrice: $0.displayPrice)
        }
    }

    // 使用 async/await 提交订单
    func submitOrder(orderId: String) async throws -> String {
        let data = try await session.submitOrder(orderId: orderId)
        guard let responseString = String(data: data, encoding: .utf8) else {
            throw CheckoutError.invalidResponse
        }
        return responseString
    }
}

// 自定义错误类型
enum CheckoutError: Error {
    case invalidResponse
}

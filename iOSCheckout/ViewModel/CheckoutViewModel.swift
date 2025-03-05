//
//  CheckoutViewModel.swift
//  iOSCheckout
//
//  Created by yousanflics on 3/3/25.
//

import SwiftUI

@MainActor
class CheckoutViewModel: ObservableObject {
    @Published var orderItems: [OrderItem] = []
    @Published var isLoading = true
    @Published var errorMsg: String?
    @Published var isSubmitting = false
    @Published var navigateToStatus = false
    
    private let checkoutService = CheckoutService()

    func loadOrder() async {
        isLoading = true
        do {
            orderItems = try await checkoutService.fetchOrder()
        } catch {
            errorMsg = "Failed to load order: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func submitOrder() async {
        isSubmitting = true
        do {
            let response = try await checkoutService.submitOrder(orderId: UUID().uuidString)
            print("Order submitted: \(response)")
            navigateToStatus = true
        } catch {
            errorMsg = "Submit order failed: \(error.localizedDescription)"
        }
        isSubmitting = false
    }
}

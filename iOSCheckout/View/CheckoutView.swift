//
//  CheckoutView.swift
//  iOSCheckout
//
//  Created by yousanflics on 3/3/25.
//
import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                contentView
                Spacer()
                submitButton
                NavigationLink(
                    destination: OrderStateView(),
                    isActive: $viewModel.navigateToStatus
                ) {
                    EmptyView()
                }
                .hidden()

            }
            .navigationTitle("Checkout")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            Task {
                await viewModel.loadOrder()
            }
        }
    }
}

extension CheckoutView {
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView("Loading order...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        } else if let errorMsg = viewModel.errorMsg {
            Text(errorMsg)
                .foregroundColor(.red)
                .padding()
        } else {
            List(viewModel.orderItems) { item in
                OrderItemRow(item: item)
            }
        }
    }
    
    @ViewBuilder
    private var submitButton: some View {
        if viewModel.isSubmitting {
            ProgressView("Processing...")
                .progressViewStyle(CircularProgressViewStyle())
                .padding()
        } else {
            Button("Submit Order") {
                Task {
                    await viewModel.submitOrder()
                }
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
}


struct OrderItemRow: View {
    let item: OrderItem

    var body: some View {
        NavigationLink(destination: ProductDetailView(item: item)) {
            VStack(alignment: .leading) {
                Text(item.itemName)
                    .font(.headline)
                Text(item.displayPrice)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
        }
    }
}


struct ProductDetailView: View {
    let item: OrderItem

    var body: some View {
        VStack {
            Text(item.itemName)
                .font(.largeTitle)
                .padding()

            Text("Price: \(item.displayPrice)")
                .font(.title2)
                .foregroundColor(.gray)
                .padding()

            Spacer()
        }
        .navigationTitle("Product Details")
        .padding()
    }
}


struct OrderStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Status: Preparing Order")
                .font(.headline)
            Spacer()
        }
        .navigationTitle("Order Status")
    }
}

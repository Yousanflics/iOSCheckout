//
//  LocalNetworkSession.swift
//  iOSCheckout
//
//  Created by yousanflics on 3/3/25.
//

import Foundation
import Combine

private let orderResponseFileURL: URL = {
    let path = Bundle.main.path(forResource: "OrderResponse", ofType: "json")!
    return URL(fileURLWithPath: path)
}()

private let submissionResponseFileURL: URL = {
    let path = Bundle.main.path(forResource: "SubmissionResponse", ofType: "json")!
    return URL(fileURLWithPath: path)
}()


class LocalNetworkSession {
    private static let queue = DispatchQueue(label: "com.yousanflics.demo-queue", qos: .background)
    
    /// Foundation handler
    // get order list data
    func getOrder() async -> Data {
        try? await Task.sleep(nanoseconds: UInt64(1 * 1_000_000_000))
        return try! Data(contentsOf: orderResponseFileURL)
    }
    
    // submit order
    func submitOrder(orderId: String) async -> Data {
        print("Submitting order with id: \(orderId)")
        try? await Task.sleep(nanoseconds: UInt64(1 * 1_000_000_000))
        return try! Data(contentsOf: submissionResponseFileURL)
    }
    
    
    
    /// Combine handler
    //
    let getOrderPublisher = LocalNetworkPublisher(fileURL: orderResponseFileURL).subscribe(on: LocalNetworkSession.queue)
    
    //
    let submitOrderPublisher = LocalNetworkPublisher(fileURL: submissionResponseFileURL).subscribe(on: LocalNetworkSession.queue)
    
    //
    func getOrder(completionHandler: @escaping (Data) -> Void) {
        LocalNetworkSession.queue.asyncAfter(deadline: .now() + 1.0) {
            let data = try! Data(contentsOf: orderResponseFileURL)
            completionHandler(data)
        }
    }
    
    /// Candidates should not modify this method
    func submitOrder(orderId: String, completionHandler: @escaping (Data) -> Void) {
        print("Submitting order with id: \(orderId)")
        LocalNetworkSession.queue.asyncAfter(deadline: .now() + 1.0) {
            let data = try! Data(contentsOf: submissionResponseFileURL)
            completionHandler(data)
        }
    }
    
}

struct LocalNetworkPublisher: Publisher {
    typealias Output = Data
    typealias Failure = Error
    
    let fileURL: URL
    
    func receive<S>(subscriber: S) where S : Subscriber, any Failure == S.Failure, Data == S.Input {
        let subscription = FileSubscription(fileURL: fileURL, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

private class FileSubscription<S: Subscriber>: Subscription where S.Input == Data, S.Failure == Error {
    private let fileURL: URL
    private var subscriber: S?
    
    init(fileURL: URL, subscriber: S) {
        self.fileURL = fileURL
        self.subscriber = subscriber
    }
    
    func request(_ demand: Subscribers.Demand) {
        if demand > 0 {
            do {
                let data = try Data(contentsOf: fileURL)
                _ = subscriber?.receive(data)
                subscriber?.receive(completion: .finished)
            } catch {
                subscriber?.receive(completion: .failure(error))
            }
        }
    }
    
    func cancel() {
        subscriber = nil
    }
}

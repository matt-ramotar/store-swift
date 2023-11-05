import Combine
import Foundation

import Combine
import Foundation


/// `ThreadSafeReplaySubject` is a custom Combine `Subject` that buffers a specified number of values
/// and ensures thread safety when sending values or handling subscriptions.
///
/// This subject is designed to hold and replay a certain number of values (defined by `bufferSize`)
/// to new subscribers or existing subscribers upon request, ensuring that they receive recent values
/// even if they subscribe after the values have been sent.
///
/// Usage:
///
///     let subject = ThreadSafeReplaySubject<Int, Never>(bufferSize: 2)
///     subject.send(1)
///     subject.send(2)
///     subject.eraseToAnyPublisher().sink { print($0) } // Prints: 1, 2
///     subject.send(3)
///     subject.eraseToAnyPublisher().sink { print($0) } // Prints: 2, 3
///
class ThreadSafeReplaySubject<Output, Failure: Error>: Subject {

    
    private let subject = PassthroughSubject<Output, Failure>()
    private let queue = DispatchQueue(label: "com.dropbox.ios.store.ThreadSafeReplaySubject", attributes: .concurrent)
    private var buffer: [Output] = []
    private let bufferSize: Int
    
    /// Creates a new `ThreadSafeReplaySubject` with a specified buffer size.
    ///
    /// - Parameter bufferSize: The maximum number of values to buffer.
    init(bufferSize: Int) {
        self.bufferSize = bufferSize
    }
    
    /// Sends a value to the subject, to be received by all subscribers.
    ///
    /// Values are also stored in a buffer, up to the specified buffer size.
    ///
    /// - Parameter value: The value to send.
    func send(_ value: Output) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.buffer.append(value)
            if self.buffer.count > self.bufferSize {
                self.buffer.removeFirst()
            }
            self.flushBuffer()
        }
    }
    
    
    /// Sends a completion to the subject, to be received by all subscribers.
    ///
    /// Before sending the completion, all buffered values are sent to ensure subscribers
    /// receive all values before the completion.
    ///
    /// - Parameter completion: The completion to send.
    func send(completion: Subscribers.Completion<Failure>) {
        queue.async(flags: .barrier) { [weak self] in
            self?.flushBuffer()
            self?.subject.send(completion: completion)
        }
    }
    
    /// Sends a subscription to the subject.
    ///
    /// - Parameter subscription: The subscription to send.
    func send(subscription: Subscription) {
        queue.async { [weak self] in
            self?.subject.send(subscription: subscription)
        }
    }
    
    /// Subscribes a subscriber to the subject.
    ///
    /// - Parameter subscriber: The subscriber to subscribe.
    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        self.subject.subscribe(subscriber)
        queue.async {
            self.flushBuffer()
        }
    }
    
    /// Flushes the buffer by sending all buffered values to all subscribers.
    private func flushBuffer() {
        queue.async { [weak self] in
            guard let self = self else { return }
            while !self.buffer.isEmpty {
                let value = self.buffer.removeFirst()
                self.subject.send(value)
            }
        }
    }
    
    /// Erases the type of the subject and returns it as an `AnyPublisher`.
    ///
    /// - Returns: An `AnyPublisher` version of the subject.
    func eraseToAnyPublisher() -> AnyPublisher<Output, Failure> {
        return subject.eraseToAnyPublisher()
    }
}

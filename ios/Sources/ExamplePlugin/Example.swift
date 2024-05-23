import Foundation

@objc public class Example: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}

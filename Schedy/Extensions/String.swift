import Foundation

extension String {
    func truncated(maxLength: Int = 25, trailing: String = "...") -> String {
        return (self.count > maxLength) ? self.prefix(maxLength) + trailing : self
    }
}

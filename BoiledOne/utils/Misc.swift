import Cocoa

extension NSRange {
    static var notFound: NSRange {
        return NSRange(location: NSNotFound, length: NSNotFound)
    }
}

extension SignedInteger {
    func modulo(_ n: Self) -> Self {
        let r = self % n
        return r < 0 ? r + abs(n) : r
    }
}

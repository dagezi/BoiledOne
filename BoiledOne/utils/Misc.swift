import Cocoa

extension NSRange {
    static var notFound: NSRange {
        return NSRange(location: NSNotFound, length: NSNotFound)
    }
}

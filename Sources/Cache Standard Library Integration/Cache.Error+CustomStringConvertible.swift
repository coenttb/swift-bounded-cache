public import Cache

extension Cache.Error: CustomStringConvertible {

    public var description: String {
        switch self {
        case .computeFailed(let error):
            "Cache.Error.computeFailed(\(error))"

        case .cancelled:
            "Cache.Error.cancelled"
        }
    }
}

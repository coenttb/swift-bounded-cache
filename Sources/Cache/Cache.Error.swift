extension Cache {

    public enum Error: Swift.Error, Sendable {

        case computeFailed(any Swift.Error)

        case cancelled
    }
}

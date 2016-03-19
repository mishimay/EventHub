public struct EventKit {

    private struct Observation {
        weak var observer: AnyObject?
        let block: Any
    }

    private static var observations = [Observation]()

    public static func addObserver<T: EventType>(observer: AnyObject, block: T -> ()) {
        observations.append(Observation(observer: observer, block: block))
    }

    public static func post<T: EventType>(event: T) {
        // remove
        observations = observations.filter { $0.observer != nil }

        observations.flatMap { $0.block as? T -> () }.forEach { $0(event) }
    }

}

public protocol EventType {}

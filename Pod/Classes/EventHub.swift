public protocol EventType {}

public enum Thread {
    case Main
    case Background(queue: dispatch_queue_t?)

    private var queue: dispatch_queue_t {
        switch self {
        case .Main:
            return dispatch_get_main_queue()
        case .Background(let queue):
            return queue ?? dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        }
    }
}

public struct EventHub {

    private struct Observation {
        weak var observer: AnyObject?
        let thread: Thread?
        let block: Any
    }

    private static var observations = [Observation]()

    public static func addObserver<T: EventType>(observer: AnyObject, thread: Thread? = nil, block: T -> ()) {
        observations.append(Observation(observer: observer, thread: thread, block: block))
    }

    public static func removeObserver(observer: AnyObject) {
        observations = observations.filter { $0.observer! !== observer }
    }

    public static func post<T: EventType>(event: T) {
        observations = observations.filter { $0.observer != nil } // Remove nil observers
        observations.forEach {
            if let block = $0.block as? T -> () {
                if let queue = $0.thread?.queue {
                    dispatch_async(queue) {
                        block(event)
                    }
                } else {
                    block(event)
                }
            }
        }
    }

}

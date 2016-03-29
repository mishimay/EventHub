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

private struct Observation {
    weak var observer: AnyObject?
    let thread: Thread?
    let block: Any
}

public struct EventHub {
    private static var observations = [Observation]()
    private static let lock: AnyObject = NSUUID().UUIDString

    public static func addObserver<T: EventType>(observer: AnyObject, thread: Thread? = nil, block: T -> ()) {
        sync {
            observations.append(Observation(observer: observer, thread: thread, block: block))
        }
    }

    public static func removeObserver(observer: AnyObject) {
        sync {
            observations = observations.filter { $0.observer! !== observer }
        }
    }

    public static func post<T: EventType>(event: T) {
        sync {
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

    private static func sync(@noescape block: () -> ()) {
        objc_sync_enter(lock)
        block()
        objc_sync_exit(lock)
    }
}

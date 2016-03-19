// https://github.com/Quick/Quick

import Quick
import Nimble
import EventKit

enum LoginEvent: EventType {
    case Success(Int)
    case Failure
}

class Observer {}

class EventKitSpec: QuickSpec {
    override func spec() {

        describe("event") {
            var result: Int!
            var observer: Observer?

            context("when the block is run synchronously on the posting thread") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    EventKit.addObserver(observer!) { (event: LoginEvent) in
                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        EventKit.removeObserver(observer)
                    }
                }

                it("is observed") {
                    EventKit.post(LoginEvent.Success(1))
                    expect(result) == 1
                }

                it("is observed multiple times") {
                    EventKit.post(LoginEvent.Success(1))
                    EventKit.post(LoginEvent.Success(2))
                    EventKit.post(LoginEvent.Success(3))
                    expect(result) == 6
                }
                
                it("isn't observed if observer is deinited") {
                    observer = nil
                    EventKit.post(LoginEvent.Success(1))
                    expect(result) == 0
                }
            }

            context("when the block is run asynchronously on the main thread") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    EventKit.addObserver(observer!, thread: .Main) { (event: LoginEvent) in
                        expect(NSThread.isMainThread()) == true

                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        EventKit.removeObserver(observer)
                    }
                }

                it("is observed") {
                    EventKit.post(LoginEvent.Success(1))
                    expect(result).toEventually(equal(1))
                }
            }

            context("when the block is run asynchronously on the background thread") {
                beforeEach {
                    result = 0
                    observer = Observer()

                    EventKit.addObserver(observer!, thread: .Background(queue: nil)) { (event: LoginEvent) in
                        expect(NSThread.isMainThread()) == false

                        switch event {
                        case .Success(let i):
                            result = result + i
                        case .Failure:
                            break
                        }
                    }
                }
                afterEach {
                    if let observer = observer {
                        EventKit.removeObserver(observer)
                    }
                }

                it("is observed") {
                    EventKit.post(LoginEvent.Success(1))
                    expect(result).toEventually(equal(1))
                }
            }
        }
    }
}

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
            beforeEach {

            }

            it("is observed") {
                var result = 0
                var observer: Observer? = Observer()
                EventKit.addObserver(observer!) { (event: LoginEvent) in
                    switch event {
                    case .Success(let i):
                        result += i
                    case .Failure:
                        break
                    }
                }

                EventKit.post(LoginEvent.Success(1))

                expect(result) == 1
            }

            it("isn't observed if observer is deinited") {
            }
        }
    }

}

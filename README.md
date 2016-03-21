# EventHub

Type-safe and handy observation system in Swift.

## Quick Example
```swift
struct MessageEvent: EventType {
    let message: String
}

EventHub.addObserver(self) { (event: MessageEvent) in
    print(event.message) // -> 😜
}
EventHub.post(MessageEvent(message: "😜"))
```

## Usage

1. **Define events which adopt `EventType` protocol**  
  The event can be a class, structure, or enumeration.

  ```swift
  enum LoginEvent: EventType {
      case Success(id: String)
      case Failure(error: ErrorType)
  }
  ```

1. **Add observers and blocks**  
  Call `addObserver(observer:thread:block:)`.  
  -  `observer`: An observer object. If the observer object is destroyed, the observation will be removed automatically and the block will never be called.
  -  `thread`: Optional (default is nil). It determines that which thread executes the block. If it's nil, the block is run synchronously on the posting thread.
  -  `block`: A callback closure. The block receives the defined event.

  ```swift
  EventHub.addObserver(self, thread: .Main) { (event: LoginEvent) in
      switch event {
      case .Success(let id):
          print(id)
      case .Failure(let error):
          print(error)
      }
  }
  ```

1. **Post events**  
  ```swift
  EventHub.post(LoginEvent.Success(id: id))
  ```

## Requirements

Swift 2.1

## Installation

EventHub is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "EventHub"
```

## Author

Yuki Mishima, mishimaybe@gmail.com

## License

EventHub is available under the MIT license. See the LICENSE file for more info.

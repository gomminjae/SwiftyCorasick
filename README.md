# SwiftyCorasick
[![Version](https://img.shields.io/cocoapods/v/SwiftyCorasick.svg?style=flat)](https://cocoapods.org/pods/SwiftyCorasick)
[![License](https://img.shields.io/cocoapods/l/SwiftyCorasick.svg?style=flat)](https://cocoapods.org/pods/SwiftyCorasick)
[![Platform](https://img.shields.io/cocoapods/p/SwiftyCorasick.svg?style=flat)](https://cocoapods.org/pods/SwiftyCorasick)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 16.0+
- Xcode 12.0+
- Swift 5.0+
## Installation

### Podfile
```ruby
pod 'SwiftyCorasick'
```

### Package.swift 
```swift
let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(url: "https://github.com/gomminjae/SwiftyCorasick.git")
  ],
  targets: [
    .target(name: "MyTarget", dependencies: ["SwiftyCorasick"])
  ]
)
```

## Author

gomminjae, gommj0611@naver.com

## License

SwiftyCorasick is available under the MIT license. See the LICENSE file for more info.

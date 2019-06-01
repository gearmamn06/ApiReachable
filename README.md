# ApiReachable

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)



Model based networking module using Alamofire <br />


# Requirements

iOS 10.0+ 


# Installation
## Cocoapods
```ruby
pod 'ApiReachable'
```



# Features
- Networking task using Alamofire for reach and get data model from your API
- Parsing using ObjectMapper or Decodable
- ApiReacbale + RxSwift


# The Basics
An app typically manages data obtained by communicating with an external API as a model. What we want is a model, but the procedure to get it sometimes requires complex and redundant tasks. <br />
ApiReachable allows you to focus on the model as you develop your app. Just explicitly declare how the model is transformed and how it calls the API. <br />
If the model you are using follows the BaseMappable or Decodable protocol, you can use the reach function declared in ApiReachable by default as follows:

```swift

    struct JazzMusic: Decodable {

        let songID: String
        let title: String
        let artist: String
    }

    extension JazzMusic: ApiReachable {

        /// Base URL of the API
        static var baseURL: URL {
            return URL(string: "https://www.mytestapi.com")
        }

        /// required path for each model.
        static var endPoint: String {
            return "songs"
        }

        /// Commonly required parameters for the same model
        static var requiredParams: [String: Any] {
            return [
                "genre": "jazz"
            ]
        }
    }

    ...

    // Pass the HTTP Method and the parameters required at runtime.
    JazzMusic.reach(method: .get, queries: ["title": "my song"]) { result in

        switch result {
            case .success(let song):
                print("found song: \(song)")

            case .failure(let error):
                print("fetch error: \(error)")
        }
    }

```

# NetworkS

### Classic networking package for iOS (version >= 13.0)

<br>

## List of features
- **NetworkS** utilizes fundamental `URLSession` with GCD under the hood
- **NetworkS** uses callback based approach for request making
- All interactions with NetworkS are based on protocols, so you can make your own implementations of
`NetworkSessionInterface` or `NetworkService`
- **NetworkS** provides logger that prints beautifully crafted request/response events into *Xcode* console
- **NetworkS** provides the opportunity to renew session by updating authorization
- **NetworkS** supports SSL certificate pinning along with default challenge
- **NetworkS** supports easily implemented response mocking
- **NetworkS** supports response caching feature

<br>

## Example of use

#### Creating URL list
```Swift
import NetworkS

struct HttpbinOrgURL {

    let path: String
    var host: String { "httpbin.org" }
}

extension HttpbinOrgURL: RequestURLExtensible {

    static let uuid = Self("/uuid")
}

```

#### Describing request
```Swift
import NetworkS

final class UUIDRequest: NetworkRequestExtensible {

    var url: RequestURL { HttpbinOrgURL.uuid }
    var method: RequestMethod { .GET }
}

```

#### Making the request
```Swift
import NetworkS

// Create session interface and use it across the app
let sessionAdapter = NetworkSessionAdapter()
sessionAdapter.sslCertificateCheck = .enabled(allowDefault: true)

// Work with a new instance of network service
let worker = NetworkWorker(sessionInterface: sessionAdapter)

let request = UUIDRequest()
let task = worker.buildTask(from: request) { response in
    if response.success,
       let body = response.jsonBody,
       let uuidString = body["uuid"] as? String {
        print("UUID: " + uuidString)
    }
}

task?.run()
```

<br>

## License

**NetworkS** is released under the **MIT** license

# NetworkS

### Classic networking package for iOS (version >= 13.0)

<br>

## List of features
- NetworkS utilizes fundamental `URLSession` under the hood
- NetworkS uses callback based approach for request making
- All interactions with NetworkS are based on protocols, so you can make your own implementations of
`NetworkSessionInterface`, `NetworkService`
- NetworkS provides logger that prints beautifully crafted request/response events into *Xcode* console
- NetworkS provides the opportunity to renew session by updating authorization
- NetworkS supports SSL certificate pinning along with default challenge
- NetworkS supports easily implemented response mocking

<br>

## Example of use

#### Creating URL list
```Swift
import NetworkS

struct HttpbinOrgURL: RequestURLExtensible {

    let path: String
    var host: String { "httpbin.org" }
}

extension HttpbinOrgURL {

    static let uuid = Self("/uuid")
}

```

#### Describing request
```Swift
import NetworkS

class UUIDRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.uuid }
    var method: RequestMethod { .GET }
    var encoding: RequestContentEncoding { .url }
}

```

#### Making the request
```Swift
import NetworkS

// Create session interface and use it across the app
let sessionAdapter = NetworkSessionAdapter()
sessionAdapter.defaultSSLChallengeEnabled = true

// Work with a new instance of network service
let worker = NetworkWorker(sessionInterface: sessionAdapter)

let request = UUIDRequest()
let task = networkService.buildTask(from: request) { response in
    if response.success,
       let body = response.jsonBody,
       let uuidString = body["uuid"] as? String {
        print("UUID: " + uuidString)
    }
}

```

<br>

## License

**NetworkS** is released under the **MIT** license

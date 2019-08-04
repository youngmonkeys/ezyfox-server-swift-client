# ezyfox-server-swift-client <img src="https://github.com/youngmonkeys/ezyfox-server/blob/master/logo.png" width="48" height="48" />
swift client for ezyfox server

# Synopsis

swift client for ezyfox server

# Code Example

**1. Create a TCP Client**

```swift
let clients = EzyClients.getInstance()!;
let config = NSMutableDictionary()
config["clientName"] = "first";
config["zoneName"] = "freechat"
client = clients.newDefaultClient(config: config)
```

**2. Setup client**

```swift
let setup = client!.setup!
.addEventHandler(eventType: EzyEventType.CONNECTION_SUCCESS, handler: EzyConnectionSuccessHandler())
.addEventHandler(eventType: EzyEventType.CONNECTION_FAILURE, handler: EzyConnectionFailureHandler())
.addDataHandler(cmd: EzyCommand.LOGIN, handler: ExLoginSuccessHandler())
.addDataHandler(cmd: EzyCommand.APP_ACCESS, handler: ExAppAccessHandler())
let handshaker = ExHandshakeHandler(username: username, password: password)
_ = client!.setup!
    .addDataHandler(cmd: EzyCommand.HANDSHAKE, handler: handshaker)
```

**3. Setup app**

```swift
_ = setup.setupApp(appName: "freechat")
    .addDataHandler(cmd: "5", handler: ExFirstAppResponseHandler())
```

**4. Connect to server**

```swift
let host = "localhost"
client!.connect(host: host, port: 3005)
```

**5. Handle socket's events on main thread**

```swift
clients.processEvents()
```

**6. Custom event handler**

```swift
class ExHandshakeHandler : EzyHandshakeHandler {
    private let username : String
    private let password : String
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    override func getLoginRequest() -> NSArray {
        let array = NSMutableArray()
        array.add("freechat")
        array.add(username)
        array.add(password)
        return array
    }
};

class ExLoginSuccessHandler : EzyLoginSuccessHandler {
    override func handleLoginSuccess(joinedApps: NSArray, responseData: NSObject) {
        let array = NSMutableArray()
        array.add("freechat")
        array.add(NSDictionary())
        client!.sendRequest(cmd: EzyCommand.APP_ACCESS, data: array)
    }
};

class ExAppAccessHandler : EzyAppAccessHandler {
    override func postHandle(app: EzyApp, data: NSObject) -> Void {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let contactView = storyboard.instantiateViewController(withIdentifier: "contactView") as! ContactViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = contactView
    }
};
```
**7. Custom app's data handler**

```swift
class ExFirstAppResponseHandler : EzyAbstractAppDataHandler<NSDictionary> {
    override func process(app: EzyApp, data: NSDictionary) {
        let mvc = Mvc.getInstance()
        let controller = mvc?.getController(name: "contact")
        controller?.updateViews(action: "init", component: "contacts", data: data)
    }
};
```

**8. Logger usage **

You should set main thread's name first:

```swift
Thread.current.name = "main";
```

Logger usage:

```swift
EzyLogger.info(msg: "access app: \(app.name) successfully")
```

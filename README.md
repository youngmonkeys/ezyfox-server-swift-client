# ezyfox-server-swift-client <img src="https://github.com/youngmonkeys/ezyfox-server/blob/master/logo.png" width="64" />
swift client for ezyfox server

# Synopsis

swift client for ezyfox server

# Documentation

[https://youngmonkeys.org/ezyfox-swift-client-sdk/](https://youngmonkeys.org/ezyfox-swift-client-sdk/)

# Using by

- [freechat](https://github.com/youngmonkeys/freechat)

# Code Example

**1. Create a TCP Client**

```swift
let config = NSMutableDictionary()
config["clientName"] = ZONE_APP_NAME
let clients = EzyClients.getInstance()!
client = clients.newClient(config: config)
```

**2. Setup client**

```swift
 let setup = client.setup!
    .addEventHandler(eventType: EzyEventType.CONNECTION_SUCCESS, handler: EzyConnectionSuccessHandler())
    .addEventHandler(eventType: EzyEventType.CONNECTION_FAILURE, handler: EzyConnectionFailureHandler())
    .addEventHandler(eventType: EzyEventType.DISCONNECTION, handler: ExDisconnectionHandler())
    .addDataHandler(cmd: EzyCommand.LOGIN, handler: ExLoginSuccessHandler())
    .addDataHandler(cmd: EzyCommand.APP_ACCESS, handler: ExAppAccessHandler())
    .addDataHandler(cmd: EzyCommand.HANDSHAKE, handler: ExHandshakeHandler())
```

**3. Setup app**

```swift
 = setup.setupApp(appName: ZONE_APP_NAME)
    .addDataHandler(cmd: Commands.GET_CONTACTS, handler: GetContactsResponseHandler())
    .addDataHandler(cmd: Commands.SEARCH_EXISTED_CONTACTS, handler: SearchExistedContactsResponseHandler())
    .addDataHandler(cmd: Commands.SUGGEST_CONTACTS, handler: SuggestContactsResponseHandler())
```

**4. Connect to server**

```swift
client.connect(host: host, port: 3005)
```

**5. Run event loop**

```swift
clients.processEvents()
```

**6. Custom event handler**

```swift
class ExDisconnectionHandler: EzyDisconnectionHandler {
    override func postHandle(event: NSDictionary) {
        // do something here
    }
}
```

**8. Logger usage**

You should set main thread's name first:

```swift
Thread.current.name = "main";
```

Logger usage:

```swift
EzyLogger.info(msg: "access app: \(app.name) successfully")
```

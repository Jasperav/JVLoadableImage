/// Not really the user info from the notification center, but this is what we want 99% of the cases anyway.
public typealias NotificationCenterUserInfo = [String: Any]

/// The generic object that will be used for sending and retrieving objects through the notification center.
public protocol NotificationCenterUserInfoMapper {
    static func mapFrom(userInfo: NotificationCenterUserInfo) -> Self
    
    func map() -> NotificationCenterUserInfo
}

/// The object that will be used to listen for notification center incoming posts.
public protocol NotificationCenterObserver: class {
    
    /// The generic object for sending and retrieving objects through the notification center.
    associatedtype T: NotificationCenterUserInfoMapper
    
    /// For type safety, only one notification name is allowed.
    /// Best way is to implement this as a let constant.
    static var notificationName: Notification.Name { get }
    
    /// The selector executor that will be used as a bridge for Objc - C compability.
    var selectorExecutor: NotificationCenterSelectorExecutor! { get set }
    
    /// Required implementing method when the notification did send a message.
    func retrieved(observer: T)
}

public extension NotificationCenterObserver {
    /// This has to be called exactly once. Best practise: right after 'self' is fully initialized.
    func register() {
        assert(selectorExecutor == nil, "You called twice the register method. This is illegal.")
        
        selectorExecutor = NotificationCenterSelectorExecutor(execute: retrieved)
        
        NotificationCenter.default.addObserver(selectorExecutor, selector: #selector(selectorExecutor.hit), name: Self.notificationName, object: nil)
    }
    
    /// Retrieved non type safe information from the notification center.
    /// Making a type safe object from the user info.
    func retrieved(userInfo: NotificationCenterUserInfo) {
        retrieved(observer: T.mapFrom(userInfo: userInfo))
    }
    
    /// Post the observer to the notification center.
    func post(observer: T) {
        NotificationCenter.default.post(name: Self.notificationName, object: nil, userInfo: observer.map())
    }
}

/// Bridge for using Objc - C methods inside a protocol extension.
public class NotificationCenterSelectorExecutor {
    
    /// The method that will be called when the notification center did send a message.
    private let execute: ((_ userInfo: NotificationCenterUserInfo) -> ())
    
    public init(execute: @escaping ((_ userInfo: NotificationCenterUserInfo) -> ())) {
        self.execute = execute
    }
    
    /// The notification did send a message. Forwarding to the protocol method again.
    @objc fileprivate func hit(_ notification: Notification) {
        execute(notification.userInfo! as! NotificationCenterUserInfo)
    }
}

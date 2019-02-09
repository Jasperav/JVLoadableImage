import JVGenericNotificationCenter

public struct NotificationCenterImageUserInfo: NotificationCenterUserInfoMapper {
    private enum Key: String {
        case photoIdentifier, photo
    }
    
    public let photoIdentifier: Int64
    public let photo: UIImage
    
    public init(photoIdentifier: Int64, photo: UIImage) {
        self.photoIdentifier = photoIdentifier
        self.photo = photo
    }
    
    public static func mapFrom(userInfo: NotificationCenterUserInfo) -> NotificationCenterImageUserInfo {
        return NotificationCenterImageUserInfo(photoIdentifier: userInfo[Key.photoIdentifier.rawValue] as! Int64,
                                                       photo: userInfo[Key.photo.rawValue] as! UIImage)
    }
    
    public func map() -> NotificationCenterUserInfo {
        return [
            Key.photoIdentifier.rawValue: photoIdentifier,
            Key.photo.rawValue: photo
        ]
    }
}

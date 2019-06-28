import JVGenericNotificationCenter

public struct NotificationCenterMediaSender: NotificationCenterSendable, Codable {
    
    public enum Media: Int, Codable {
        case image, videoThumbnail
    }
    
    public enum Update {
        case image(UIImage, Media, identifier: Int64, size: Int), identifier(Int64, Int, Int64)
    }

    public static let notificationName = Notification.Name.retrievedLoadableImage
    
    let size: Int
    let identifier: Int64
    
    private let image: Data?
    private let media: Media?
    private let newIdentifier: Int64?
    
    var update: Update {
        if let image = image {
            return .image(UIImage(data: image)!, media!, identifier: identifier, size: size)
        } else {
            return .identifier(identifier, size, newIdentifier!)
        }
    }
    
    public init(update: Update) {
        switch update {
        case .image(let image, let media, let identifier, let size):
            self.identifier = identifier
            self.size = size
            self.image = image.pngData()!
            self.media = media
            self.newIdentifier = nil
        case .identifier(let identifier, let size, let newIdentifier):
            self.identifier = identifier
            self.size = size
            image = nil
            media = nil
            self.newIdentifier = newIdentifier
        }
    }
    

}

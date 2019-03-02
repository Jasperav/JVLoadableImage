import UIKit
import JVConstraintEdges
import JVGenericNotificationCenter
import JVUIButtonExtensions

/// Presents a loading view wich acts like a placeholder for an upcoming image.
open class LoadableImage: UIView, NotificationCenterObserver {

    public typealias T = NotificationCenterImageUserInfo
    
    public private (set) var isLoading = true
    
    public var selectorExecutor: NotificationCenterSelectorExecutor!
    
    // The identifier for the photo. Can later be used to set the image on if it is done loading.
    public var identifier: Int64 = 0
    
    public var tapped: (() -> ())!
    
    private let image = UIButton(frame: .zero)
    private let indicator: UIActivityIndicatorView
    private let rounded: Bool
    
    public init(style: UIActivityIndicatorView.Style = .gray,
                rounded: Bool,
                registerNotificationCenter: Bool = true,
                tapped: (() -> ())? = nil,
                isUserInteractionEnabled: Bool = true) {
        indicator = UIActivityIndicatorView(style: style)
        self.rounded = rounded
        self.image.clipsToBounds = rounded
        self.tapped = tapped
        
        super.init(frame: .zero)
        
        assert(tapped != nil ? isUserInteractionEnabled : true)
        
        if registerNotificationCenter {
            register()
        }
        
        addImage(isUserInteractionEnabled: isUserInteractionEnabled)
        addIndicator()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Will show an image with an indicator to indicate a higher resolution photo is being downloaded
    open func show(blurredImage: UIImage) {
        image.setImage(blurredImage, for: .normal)
        image.alpha = 1
        image.isUserInteractionEnabled = false
        indicator.alpha = 1
        isLoading = true
    }
    
    open func show(image: UIImage) {
        self.image.setImage(image, for: .normal)
        self.image.alpha = 1
        self.image.isUserInteractionEnabled = true
        
        indicator.alpha = 0
        isLoading = false
    }
    
    open func showIndicator() {
        // We have to do this every time the cell reappears.
        indicator.startAnimating()
        indicator.alpha = 1
        image.alpha = 0
        image.isUserInteractionEnabled = false
        isLoading = true
    }
    
    public func stretchImage() {
        image.stretchImage()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard rounded else {
            return
        }
        
        assert(image.bounds.height == image.bounds.width, "The width of the image isn't equal to the height of the image. This is illegal.")
        
        image.layer.cornerRadius = image.bounds.height / 2
    }
    
    public func retrieved(observer: NotificationCenterImageUserInfo) {
        guard identifier == observer.photoIdentifier else { return }
        
        show(image: observer.photo)
    }
    
    @objc private func _tapped() {
        tapped!()
    }
    
    private func addIndicator() {
        indicator.fill(toSuperview: self)
        
        indicator.startAnimating()
    }
    
    private func addImage(isUserInteractionEnabled: Bool) {
        image.fill(toSuperview: self)
        
        image.imageView!.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = isUserInteractionEnabled
        
        guard image.isUserInteractionEnabled else {
            // Without this, the image sometimes gets enabled again, dunno why...
            isUserInteractionEnabled = false
            
            return
        }
        
        image.addTarget(self, action: #selector(_tapped), for: .touchUpInside)
    }
}

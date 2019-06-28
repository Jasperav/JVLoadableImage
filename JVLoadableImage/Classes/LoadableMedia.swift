import UIKit
import JVConstraintEdges
import JVGenericNotificationCenter
import JVUIButton
import JVDebugProcessorMacros
import AVKit

/// Presents a loading view wich acts like a placeholder for  upcoming media.
open class LoadableMedia: UIView, NotificationCenterObserver {
    
    public enum State {
        case
        loading,
        highResolutionImage(UIImage),
        blurredImageWithIndicator(UIImage),
        videoThumbnail(UIImage),
        video(URL)
        
        var isLoading: Bool {
            switch self {
            case .loading: return true
            default: return false
            }
        }
    }

    public typealias MappedType = NotificationCenterMediaSender
    
    public private (set) var imageView: UIImageView!
    
    public var isLoading: Bool {
        return state.isLoading
    }

    public private (set) var state = State.loading
    
    public var selectorExecutor: NotificationCenterSelectorExecutor!
    
    // The identifier for the media. Can later be used to set the media on if it is done loading.
    public var identifier: Int64 = 0
    public var size = 0
    
    public var presentedHighResolutionImage: (() -> ())? = nil
    public var present: ((URL) -> ())!
    public var tapped: (() -> ())!
    
    private let showVideoButton = UIButton(frame: .zero)
    private let imageButton = UIButton(frame: .zero)
    private let indicator: UIActivityIndicatorView
    private let rounded: Bool

    public init(style: UIActivityIndicatorView.Style = .medium,
                rounded: Bool,
                registerNotificationCenter: Bool = true,
                tapped: (() -> ())? = nil,
                isUserInteractionEnabled: Bool = true,
                stretched: Bool = false) {
        indicator = UIActivityIndicatorView(style: style)
        self.rounded = rounded
        self.imageButton.clipsToBounds = rounded
        self.tapped = tapped
        
        super.init(frame: .zero)
        
        assert(tapped != nil ? isUserInteractionEnabled : true)
        
        layoutImage(isUserInteractionEnabled: isUserInteractionEnabled)
        layoutIndicator()
        layoutShowVideoButton()
        
        if registerNotificationCenter {
            register()
        }
        
        if stretched {
            // TODO: Link JVUIButton
            imageButton.stretchImage()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard rounded else {
            return
        }
        
        assert(imageButton.bounds.height.rounded() == imageButton.bounds.width.rounded(), "The width of the image isn't equal to the height of the image. This is illegal.")
        
        imageButton.layer.cornerRadius = imageButton.bounds.height / 2
    }
    
    open func change(state: State, identifier: Int64, size: Int) {
        assert(Thread.isMainThread)
        
        guard self.identifier == identifier && self.size == size else { return }
        
        forceChange(state: state)
    }
    
    open func forceChange(state: State) {
        switch state {
        case .loading:
            showIndicator()
        case .highResolutionImage(let image):
            show(image: image)
            showVideoButton.isHidden = true
            presentedHighResolutionImage?()
        case .blurredImageWithIndicator(let image):
            show(blurredImage: image)
            showVideoButton.isHidden = true
        case .videoThumbnail(let image):
            show(image: image)
            showVideoButton.isHidden = false
        case .video(let url):
            present(url)
        }
        
        self.state = state
    }
    
    private func showIndicator() {
        indicator.startAnimating()
        indicator.alpha = 1
        
        imageButton.alpha = 0
        imageButton.isUserInteractionEnabled = false
        showVideoButton.isHidden = true
    }
    
    private func show(blurredImage: UIImage) {
        imageButton.setImage(blurredImage, for: .normal)
        imageButton.alpha = 1
        imageButton.isUserInteractionEnabled = false
        indicator.alpha = 1
    }
    
    private func show(image: UIImage) {
        imageButton.setImage(image, for: .normal)
        imageButton.alpha = 1
        imageButton.isUserInteractionEnabled = true
        
        indicator.alpha = 0
    }
    
    private func show(video: URL) {
        
    }
    
    public func retrieved(observer: NotificationCenterMediaSender) {
        switch observer.update {
        case .image(let image, let media, _, _):
            switch media {
            case .image:
                change(state: .highResolutionImage(image), identifier: observer.identifier, size: observer.size)
            case .videoThumbnail:
                change(state: .videoThumbnail(image), identifier: observer.identifier, size: observer.size)
            }
        case .identifier(_, _, let newIdentifier):
            identifier = newIdentifier
        }
    }
    
    @objc private func _tapped() {
        tapped!()
    }
}

extension LoadableMedia: ViewLayout {
    private func layoutIndicator() {
        indicator.layout(in: self)
        
        indicator.startAnimating()
    }
    
    private func layoutImage(isUserInteractionEnabled: Bool) {
        imageView = imageButton.imageView!
        
        imageButton.layout(in: self)
        imageButton.imageView!.contentMode = .scaleAspectFit
        imageButton.isUserInteractionEnabled = isUserInteractionEnabled
        
        guard imageButton.isUserInteractionEnabled else {
            // Without this, the image sometimes gets enabled again, dunno why...
            self.isUserInteractionEnabled = false
            
            return
        }
        
        imageButton.addTarget(self, action: #selector(_tapped), for: .touchUpInside)
    }
    
    private func layoutShowVideoButton() {
        showVideoButton.layoutInMiddle(inView: self)
        
        showVideoButton.layoutConstant(height: 60)
        showVideoButton.layoutSquare()
        showVideoButton.stretchImage()
        
        showVideoButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
        showVideoButton.addTarget(self, action: #selector(_tapped), for: .touchUpInside)
        showVideoButton.isHidden = true
    }
}

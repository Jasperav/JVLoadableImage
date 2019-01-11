import UIKit
import JVConstraintEdges

/// Presents a loading view wich acts like a placeholder for an upcoming image.
open class LoadableImage: UIView {
    
    private let indicator = UIActivityIndicatorView(style: .white)
    private let image = UIButton(frame: .zero)
    private let tapped: (() -> ())!
    
    public init(tapped: (() -> ())? = nil) {
        self.tapped = tapped
        
        super.init(frame: .zero)
        
        addIndicator()
        addImage()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func show(image: UIImage) {
        self.image.imageView!.image = image
        
        self.image.alpha = 1
        indicator.alpha = 0
    }
    
    open func showIndicator() {
        image.alpha = 0
        indicator.alpha = 1
    }
    
    @objc private func _tapped() {
        tapped!()
    }
    
    private func addIndicator() {
        indicator.fill(toSuperview: self)
        
        indicator.startAnimating()
    }
    
    private func addImage() {
        image.fill(toSuperview: self)
        
        image.imageView!.contentMode = .scaleAspectFit
        image.isUserInteractionEnabled = tapped != nil
        
        guard image.isUserInteractionEnabled else { return }
        
        image.addTarget(self, action: #selector(_tapped), for: .touchUpInside)
    }
}

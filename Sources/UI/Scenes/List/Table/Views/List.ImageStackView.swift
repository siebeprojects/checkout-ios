#if canImport(UIKit)
import UIKit

extension List.Table {
    /// UIStackView with proportionally scaled images with support of `intrinsicContentSize`.
    final class ImageStackView: UIStackView {
        let imagesTintColor: UIColor
        
        init(frame: CGRect, imagesTintColor: UIColor) {
            self.imagesTintColor = imagesTintColor
            super.init(frame: frame)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var images = [UIImage]() {
            didSet {
                setImages(images)
            }
        }
        
        private func setImages(_ images: [UIImage]) {
            arrangedSubviews.forEach {
                self.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            
            for image in images {
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                imageView.tintColor = imagesTintColor
                
                imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
                
                addArrangedSubview(imageView)
                
                guard image.size.height != 0 else { continue }
                
                // Eliminate a free space around the image
                let imageAspectRatio = image.size.width / image.size.height
                imageView.widthAnchor.constraint(lessThanOrEqualTo: imageView.heightAnchor, multiplier: imageAspectRatio).isActive = true
            }
            
            invalidateIntrinsicContentSize()
        }
        
        override var intrinsicContentSize: CGSize {
            var totalSize = CGSize.zero
            for (index, view) in arrangedSubviews.enumerated() {
                // Add spacing before only if it is not the first item
                if index != 0 {
                    switch axis {
                    case .horizontal: totalSize.width += spacing
                    case .vertical: totalSize.height += spacing
                    @unknown default: break
                    }
                }

                let contentSize = view.intrinsicContentSize
                totalSize.height += contentSize.height
                totalSize.width += contentSize.width
            }
            
            return totalSize
        }
    }
}

private class FixedWidthAspectFitImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        guard let image = self.image else {
            return .init(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
        }
        
        print("Wanted frame: \(self.frame.size)")
        
        let aspectRatio = image.size.width / image.size.height
        let scaledHeight = frame.width * aspectRatio
        return CGSize(width: frame.width, height: scaledHeight)
    }
}
#endif

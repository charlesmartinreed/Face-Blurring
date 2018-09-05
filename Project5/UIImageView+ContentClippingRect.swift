/*
Copyright © 2017 Apple Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Abstract:
Extension on UIImageView to compute a clipping rect for an image displayed using the scale aspect fit content mode.
*/

import UIKit

extension UIImageView {
    /// Returns a rect that can be applied to the image view to clip to the image, assuming a scale aspect fit content mode.
    var contentClippingRect: CGRect {
        guard let image = image, contentMode == .scaleAspectFit else { return bounds }
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        guard imageWidth > 0 && imageHeight > 0 else { return bounds }
        
        let scale: CGFloat
        if imageWidth > imageHeight {
            scale = bounds.size.width / imageWidth
        } else {
            scale = bounds.size.height / imageHeight
        }
        
        let clippingSize = CGSize(width: imageWidth * scale, height: imageHeight * scale)
        let x = (bounds.size.width - clippingSize.width) / 2.0
        let y = (bounds.size.height - clippingSize.height) / 2.0
        
        return CGRect(origin: CGPoint(x: x, y: y), size: clippingSize)
    }
    
    
    
    
    
    
    
    
    
    
}

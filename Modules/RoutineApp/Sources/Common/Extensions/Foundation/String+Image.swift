import Foundation
import UIKit

extension String {
  var image: UIImage? {
    let nsString = (self as NSString)
    let font = Font.system(.largeTitle, weight: .regular)
    let stringAttributes = [NSAttributedString.Key.font: font]
    let imageSize = nsString.size(withAttributes: stringAttributes)
    
    UIGraphicsBeginImageContextWithOptions(imageSize, false, .zero)
    UIColor.clear.set()
    UIRectFill(CGRect(origin: CGPoint(), size: imageSize))
    nsString.draw(at: .zero, withAttributes: stringAttributes)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
  }
}

//
//  Extension UIImage.swift
//  TakeImageAVFoundation
//
//  Created by Davit Natenadze on 31.03.23.
//

import UIKit

extension UIImage {
    func scaleToFitSize(_ size: CGSize) -> UIImage {
        let aspectRatio = self.size.width / self.size.height
        let scaledSize: CGSize
        if aspectRatio > 1 {
            scaledSize = CGSize(width: size.width, height: size.width / aspectRatio)
        } else {
            scaledSize = CGSize(width: size.height * aspectRatio, height: size.height)
        }
        let renderer = UIGraphicsImageRenderer(size: scaledSize)
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
        return scaledImage
    }
}

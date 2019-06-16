//
//  SwipeButtonWithImage.swift
//  Pods-SwipeViewController_Example
//
//  Created by Marek Fořt on 6/15/19.
//

import Foundation

public struct SwipeButtonWithImage {
    var size: CGSize?
    var image: UIImage?
    var selectedImage: UIImage?

    public init(image: UIImage?, selectedImage: UIImage?, size: CGSize?) {
        self.image = image
        self.selectedImage = selectedImage
        self.size = size
    }
}

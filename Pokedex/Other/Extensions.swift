//
//  Extensions.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import UIKit

extension String {
    func firstLetterCapitalized() -> String {
        prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}

extension UIDevice {
    static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    static let isLandscape = UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
}

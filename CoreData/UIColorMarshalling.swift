//
//  UIColorMarshalling.swift
//  Tracker
//
//  Created by Кирилл Марьясов on 31.08.2024.
//

import Foundation
import UIKit

// MARK: - UIColorMarshalling Class

final class UIColorMarshalling {
    
    // MARK: - Public Methods
    
    static func hexString(from color: UIColor) -> String {
        guard let components = color.cgColor.components, components.count >= 3 else { return "000000" }
        let r = components[0]
        let g = components[1]
        let b = components[2]
        return String(
            format: "%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
    
    static func color(from hex: String) -> UIColor {
        var rgbValue: UInt64 = 0
        let scanner = Scanner(string: hex)
        scanner.scanHexInt64(&rgbValue)
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}

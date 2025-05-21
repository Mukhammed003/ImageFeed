//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 19.05.2025.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var imageOfPost: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var gradientView: UIView!
    
    static let reusedIdentifier = "ImagesListCell"
    private var gradientLayer: CAGradientLayer?
    
    override func layoutSubviews() {
            super.layoutSubviews()
            
            gradientLayer?.removeFromSuperlayer()
            
            let gradient = CAGradientLayer()
            gradient.frame = gradientView.bounds
            gradient.colors = [
                UIColor(hex: "#1A1B22").withAlphaComponent(0.0).cgColor,
                UIColor(hex: "#1A1B22").withAlphaComponent(1.0).cgColor
            ]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)

            gradientView.layer.insertSublayer(gradient, at: 0)
            self.gradientLayer = gradient
        }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}


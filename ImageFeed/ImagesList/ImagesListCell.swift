//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 19.05.2025.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    var isLikingInProgress = false
    
    @IBOutlet weak var imageOfPost: UIImageView?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var likeButton: UIButton?
    @IBOutlet weak var gradientView: UIView?
    
    weak var delegate: ImagesListCellDelegate?
    static let reusedIdentifier = "ImagesListCell"
    
    private var gradientLayer: CAGradientLayer?
    
    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer?.removeFromSuperlayer()
        
        guard let gradientView = gradientView else { return }
        
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageOfPost?.kf.cancelDownloadTask()
    }
    
    func setIsLiked(_ isLiked: Bool) {
        likeButton?.setImage(UIImage(resource: isLiked ? .likeButtonOn : .likeButtonOff), for: .normal)
        likeButton?.accessibilityIdentifier = isLiked ? "likeButtonOn" : "likeButtonOff"
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


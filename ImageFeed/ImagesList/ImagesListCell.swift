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
    
    static let reusedIdentifier = "ImagesListCell"
}

//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 24.05.2025.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var scrollView: UIScrollView?
    
    var imageURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        scrollView?.minimumZoomScale = 0.1
        scrollView?.maximumZoomScale = 1.25
        
        if let imageURL {
                imageView?.kf.setImage(with: imageURL,
                                       placeholder: UIImage(resource: .placeholderImageForPost),
                                       completionHandler: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let value):
                        let image = value.image
                        self.imageView?.frame.size = image.size
                        self.rescaleAndCenterImageInScrollView(image: image)
                    case .failure(let error):
                        print("❌ Failed to load image: \(error)")
                    }
                })
            }
    }
    
    
    @IBAction private func didTapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView?.image else { return }
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activity, animated: true, completion: nil)
    }
    
    @IBAction func didTapLikeButton(_ sender: Any) {
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        guard let scrollView = scrollView else { return }
        
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        var hScale: CGFloat = 1.0
        var vScale: CGFloat = 1.0
        
        if visibleRectSize.width != 0 && visibleRectSize.height != 0 {
            hScale = visibleRectSize.width / imageSize.width
            vScale = visibleRectSize.height / imageSize.height
        }
        else {
            print("Wrong size")
        }
        
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

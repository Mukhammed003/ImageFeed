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
        
        loadImage()
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
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })
        
        present(alert, animated: true)
    }
    
    private func loadImage() {
        guard let imageURL else { return }
            
            UIBlockingProgressHUD.show()
            imageView?.kf.setImage(with: imageURL,
                                   placeholder: UIImage(resource: .placeholderImageForPost),
                                   completionHandler: { [weak self] result in
                guard let self else { return }
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let imageResult):
                    self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                case .failure:
                    self.showError()
                }
            })
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

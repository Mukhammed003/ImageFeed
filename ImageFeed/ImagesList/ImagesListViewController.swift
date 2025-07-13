//
//  ViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 18.05.2025.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView?
    
    var photos: [Photo] = []
    
    private var imagesListService = ImagesListService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.rowHeight = 200
        tableView?.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        imagesListService.fetchPhotosNextPage()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        
        print("photos.count: \(photos.count)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            
            guard
                let viewontroller = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Something get wrong")
                return
                }
            
            if let url = URL(string: photos[indexPath.row].thumbImageURL)
               {
                viewontroller.imageURL = url
            }
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView?.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView?.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reusedIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        
        return imageListCell
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let urlOfImagePost = photos[indexPath.row].thumbImageURL
        
        guard
            let url = URL(string: urlOfImagePost)
            else {
            print("❌ Невалидный URL: \(photos[indexPath.row].thumbImageURL)")
                return
            }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        cell.imageOfPost?.kf.indicatorType = .activity
        cell.imageOfPost?.kf.setImage(with: url,
                                      placeholder: UIImage(resource: .placeholderImageForPost),
                                      options: [.processor(processor)],
                                      completionHandler: {result in
            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
        })
        
        guard let date = photos[indexPath.row].createdAt as Date? else { return }
        cell.dateLabel?.text = dateFormatter.string(from: date)
        
        photos[indexPath.row].isLiked
        ? cell.likeButton?.setImage(UIImage(resource: .likeButtonOn), for: .normal)
        : cell.likeButton?.setImage(UIImage(resource: .likeButtonOff), for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func tableView(
      _ tableView: UITableView,
      willDisplay cell: UITableViewCell,
      forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == imagesListService.photos.count {
            imagesListService.fetchPhotosNextPage()
        }
    }
}

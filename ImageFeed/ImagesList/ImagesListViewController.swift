//
//  ViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 18.05.2025.
//

import UIKit
import Kingfisher

protocol ImagesListViewProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewAnimated()
    func reloadCell(at indexPath: IndexPath)
    func showLikeError(message: String)
}

final class ImagesListViewController: UIViewController, ImagesListViewProtocol {
    
    @IBOutlet private var tableView: UITableView?
    
    var presenter: ImagesListPresenterProtocol?
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView?.rowHeight = 200
        tableView?.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        presenter?.viewDidLoad()
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
                    
            if let url = URL(string: presenter?.photo(at: indexPath.row).thumbImageURL ?? "")
                       {
                        viewontroller.imageURL = url
                    }
                    
                } else {
                    super.prepare(for: segue, sender: sender)
                }
    }
    
    // MARK: - ImagesListViewProtocol
    
    func updateTableViewAnimated() {
        tableView?.reloadData()
    }
    
    func reloadCell(at indexPath: IndexPath) {
        tableView?.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func showLikeError(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photosCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reusedIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        presenter?.configCell(cell, for: indexPath.row)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let presenter = presenter,
           indexPath.row == presenter.photosCount - 1 {
            presenter.viewDidLoad()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectImage(at: indexPath.row)
        performSegue(withIdentifier: "ShowSingleImage", sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return UITableView.automaticDimension }

            let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
            let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
            let imageSize = presenter.sizeForPhoto(at: indexPath.row)
            let scale = imageViewWidth / imageSize.width
            let cellHeight = imageSize.height * scale + imageInsets.top + imageInsets.bottom

            return cellHeight
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath.row)
    }
}

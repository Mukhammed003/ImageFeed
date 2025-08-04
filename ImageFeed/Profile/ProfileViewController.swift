//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 22.05.2025.
//

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    
    func updateProfileDetails(name: String, login: String, bio: String)
    func updateAvatar(with url: URL)
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    var presenter: ProfilePresenterProtocol?
    
    private lazy var profileImage: UIImageView = makeProfileImage()
    private lazy var emptyInFavouritesSectionImage: UIImageView = makeEmptyInFavouritesSectionImage()
    private lazy var exitButton: UIButton = makeExitButton()
    private lazy var nameLabel: UILabel = makeNameLabel()
    private lazy var emailLabel: UILabel = makeEmailLabel()
    private lazy var descriptionLabel: UILabel = makeDescriptionLabel()
    private lazy var favouritesLabel: UILabel = makeFavouritesLabel()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    deinit {
            if let observer = profileImageServiceObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Presenter is: \(String(describing: presenter))") 
        
        view.backgroundColor = .ypBlack
        
        addSubviews()
        setupConstraints()
        setupNotifications()
        presenter?.viewDidLoad()
    }
    
    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        emailLabel.text = login
        descriptionLabel.text = bio
    }
    
    func updateAvatar(with url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 64)
                profileImage.kf.indicatorType = .activity
                profileImage.kf.setImage(with: url,
                                         placeholder: UIImage(named: "placeholder.jpeg"),
                                         options: [.processor(processor)])
    }
    
    @objc func clickToExitButton() {
        let alertModel = AlertModel(
            title: "Выйти из профиля?",
            message: "Вы уверены, что хотите выйти?",
            buttonText: "Да") {
                self.presenter?.didTapLogout()
            }
        
        let alertPresenter = AlertPresenter(viewController: self)
        alertPresenter.showAlert(alert: alertModel, accessibilityIdentifier: "byeALert")
    }
    
    private func addSubviews() {
        [profileImage, exitButton, nameLabel, emailLabel, descriptionLabel, favouritesLabel, emptyInFavouritesSectionImage].forEach {
                view.addSubview($0)
            }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            
            exitButton.heightAnchor.constraint(equalToConstant: 44),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor),
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            
            emailLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            
            favouritesLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            favouritesLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            
            emptyInFavouritesSectionImage.heightAnchor.constraint(equalToConstant: 115),
            emptyInFavouritesSectionImage.widthAnchor.constraint(equalToConstant: 115),
            emptyInFavouritesSectionImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyInFavouritesSectionImage.topAnchor.constraint(equalTo: favouritesLabel.bottomAnchor, constant: 110)
            ])
    }
    
    private func setupNotifications() {
        profileImageServiceObserver = NotificationCenter.default
                .addObserver(forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                    self?.presenter?.avatarDidChange()
                }
    }
    
    private func makeProfileImage() -> UIImageView {
        let profileImage = createUIImageView(nameOfImage: "example_profile_avatar", colorForBack: .ypBlack, radiusIfNeeded: 35)
        
        return profileImage
    }
    
    private func makeEmptyInFavouritesSectionImage() -> UIImageView {
        let emptyInFavouritesSectionImage = createUIImageView(nameOfImage: "no_photo_in_favourites", colorForBack: .ypBlack, radiusIfNeeded: 0)
        
        return emptyInFavouritesSectionImage
    }
    
    private func makeExitButton() -> UIButton {
        let exitButton = createUIButton(imageForButton: "ipad.and.arrow.forward", forSelector: #selector(clickToExitButton), colorOfIcon: .ypRed)
        
        exitButton.accessibilityIdentifier = "exitButton"
        
        return exitButton
    }
    
    private func makeNameLabel() -> UILabel {
        let nameLabel = createUILabel(textOfLabel: "Екатерина Новикова", letterSpacing: 0.3, colorOfLabel: .ypWhite, fontSizeOfLabel: 23, weightOfLabel: .bold)
        
        return nameLabel
    }
    
    private func makeEmailLabel() -> UILabel {
        let emailLabel = createUILabel(textOfLabel: "@ekaterina_nov", letterSpacing: 0, colorOfLabel: .ypGray, fontSizeOfLabel: 13, weightOfLabel: .regular)
        
        return emailLabel
    }
    
    private func makeDescriptionLabel() -> UILabel {
        let descriptionLabel = createUILabel(textOfLabel: "Hello, world!", letterSpacing: 0, colorOfLabel: .ypWhite, fontSizeOfLabel: 13, weightOfLabel: .regular)
        
        return descriptionLabel
    }
    
    private func makeFavouritesLabel() -> UILabel {
        let favouritesLabel = createUILabel(textOfLabel: "Избранное", letterSpacing: 0.3, colorOfLabel: .ypWhite, fontSizeOfLabel: 23, weightOfLabel: .bold)
        
        return favouritesLabel
    }
    
    private func createUIImageView(nameOfImage imageName: String, colorForBack backgroundColor: UIColor, radiusIfNeeded cornerRadius: CGFloat) -> UIImageView {
        let exampleImage = UIImage(named: imageName)
        let exampleImageView = UIImageView(image: exampleImage)
        exampleImageView.backgroundColor = backgroundColor
        exampleImageView.clipsToBounds = true
        
        if cornerRadius != 0 {
            exampleImageView.layer.cornerRadius = cornerRadius
        }
        
        exampleImageView.translatesAutoresizingMaskIntoConstraints = false
        
        return exampleImageView
    }
    
    private func createUIButton(imageForButton systemName: String, forSelector selector: Selector, colorOfIcon tintColor: UIColor) -> UIButton {
        guard let buttonImage = UIImage(systemName: systemName) else { return UIButton() }
        let exampleButton = UIButton.systemButton(with: buttonImage, target: self, action: selector)
        exampleButton.tintColor = tintColor
        
        exampleButton.translatesAutoresizingMaskIntoConstraints = false
        
        return exampleButton
    }
    
    private func createUILabel(textOfLabel exampleText: String, letterSpacing kern: CGFloat, colorOfLabel foregroundColor: UIColor, fontSizeOfLabel fontSize: CGFloat, weightOfLabel weight: UIFont.Weight) -> UILabel {
        let exampleLabel = UILabel()
        
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let attributedString = NSAttributedString(
            string: exampleText,
            attributes: [
                .kern: kern,
                .foregroundColor: foregroundColor,
                .font: UIFont.systemFont(ofSize: fontSize, weight: weight)
            ]
        )
        exampleLabel.attributedText = attributedString
        
        return exampleLabel
    }
}

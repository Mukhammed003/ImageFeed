//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 22.05.2025.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    private var profileImage: UIImageView!
    private var emptyInFavouritesSectionImage: UIImageView!
    private var exitButton: UIButton!
    private var nameLabel: UILabel!
    private var emailLabel: UILabel!
    private var descriptonLabel: UILabel!
    private var favouritesLabel: UILabel!
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    deinit {
            if let observer = profileImageServiceObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
                }
        updateAvatar()
        
        let profileImage = createUIImageView(nameOfImage: "avatar", colorForBack: .ypBlack, radiusIfNeeded: 35)
        let exitButton = createUIButton(imageForButton: "ipad.and.arrow.forward", forSelector: #selector(clickToExitButton), colorOfIcon: .ypRed)
        let nameLabel = createUILabel(textOfLabel: "Екатерина Новикова", letterSpacing: 0.3, colorOfLabel: .ypWhite, fontSizeOfLabel: 23, weightOfLabel: .bold)
        let emailLabel = createUILabel(textOfLabel: "@ekaterina_nov", letterSpacing: 0, colorOfLabel: .ypGray, fontSizeOfLabel: 13, weightOfLabel: .regular)
        let descriptionLabel = createUILabel(textOfLabel: "Hello, world!", letterSpacing: 0, colorOfLabel: .ypWhite, fontSizeOfLabel: 13, weightOfLabel: .regular)
        let favouritesLabel = createUILabel(textOfLabel: "Избранное", letterSpacing: 0.3, colorOfLabel: .ypWhite, fontSizeOfLabel: 23, weightOfLabel: .bold)
        let emptyInFavouritesSectionImage = createUIImageView(nameOfImage: "no_photo_in_favourites", colorForBack: .ypBlack, radiusIfNeeded: 0)
        
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
        
        self.profileImage = profileImage
        self.exitButton = exitButton
        self.nameLabel = nameLabel
        self.emailLabel = emailLabel
        self.descriptonLabel = descriptionLabel
        self.favouritesLabel = favouritesLabel
        self.emptyInFavouritesSectionImage = emptyInFavouritesSectionImage
        
        guard let profile = ProfileService.shared.profile else {
            print("Ошибка при загрузке профиля")
            return }
        
        updateProfileDetails(profile: profile)
    }
    
    @objc func clickToExitButton() {}
    
    private func createUIImageView(nameOfImage imageName: String, colorForBack backgroundColor: UIColor, radiusIfNeeded cornerRadius: CGFloat) -> UIImageView {
        let exampleImage = UIImage(named: imageName)
        let exampleImageView = UIImageView(image: exampleImage)
        exampleImageView.backgroundColor = backgroundColor
        
        if cornerRadius != 0 {
            exampleImageView.layer.cornerRadius = cornerRadius
        }
        
        exampleImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exampleImageView)
        
        return exampleImageView
    }
    
    private func createUIButton(imageForButton systemName: String, forSelector selector: Selector, colorOfIcon tintColor: UIColor) -> UIButton {
        guard let buttonImage = UIImage(systemName: systemName) else { return UIButton() }
        let exampleButton = UIButton.systemButton(with: buttonImage, target: self, action: selector)
        exampleButton.tintColor = tintColor
        exampleButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exampleButton)
        
        return exampleButton
    }
    
    private func createUILabel(textOfLabel exampleText: String, letterSpacing kern: CGFloat, colorOfLabel foregroundColor: UIColor, fontSizeOfLabel fontSize: CGFloat, weightOfLabel weight: UIFont.Weight) -> UILabel {
        let exampleLabel = UILabel()
        exampleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exampleLabel)
        let exampleText = exampleText
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
    
    private func updateProfileDetails(profile: Profile) {
        self.nameLabel.text = profile.name
        self.emailLabel.text = profile.loginName
        self.descriptonLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        // TODO [Sprint 11] Обновить аватар, используя Kingfisher
    }
}

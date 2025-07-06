//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 15.06.2025.
//
import UIKit

final class SplashViewController: UIViewController {
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let profileService = ProfileService.shared
    private let oAuth2Service = OAuth2Service()
    private let storage = OAuth2TokenStorage()
    
    private var logoImage: UIImageView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .ypBlack
        
        let logoImage = createUIImageView(nameOfImage: "splash_screen_logo", colorForBack: .ypBlack, radiusIfNeeded: 0)
        
        NSLayoutConstraint.activate([
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        if let token = storage.token {
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as! AuthViewController
            viewController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true, completion: nil)
        }
        
        self.logoImage = logoImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Invalid Configuration")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
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
        view.addSubview(exampleImageView)
        
        return exampleImageView
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true)
        
        guard let token = storage.token else {
            return
        }
        
        fetchProfile(token)
    }
    
    func fetchOAuthToken(_ code: String) {
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
                switch result {
                case .success:
                    self.switchToTabBarController()
                case .failure:
                    // TODO [11 sprint]
                    break
                }
            }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                let username = profile.username
                ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in
    
                }
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
}

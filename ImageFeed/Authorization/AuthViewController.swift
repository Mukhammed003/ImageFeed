//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 07.06.2025.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    @IBOutlet weak var LoginButton: UIButton!
    
    let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    private let oauth2Service = OAuth2Service.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        
        LoginButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                print("Something get wrong when prepare for segue: \(showWebViewSegueIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        navigationController?.popToViewController(self, animated: true)
        
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
                    switch result {
                    case .success(let token):
                        print("✅ Авторизация прошла успешно, токен: \(token)")
                        delegate?.didAuthenticate(self, didAuthenticateWithCode: code)
                    case .failure(let error):
                        print("❌ Ошибка при получении токена: \(error)")
                    }
                }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}

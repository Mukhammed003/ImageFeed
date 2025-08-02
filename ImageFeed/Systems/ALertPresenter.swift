//
//  ALertPresenter.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 28.06.2025.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> Void
}

final class AlertPresenter {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }

    func showAlert(alert model: AlertModel, accessibilityIdentifier: String?) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = accessibilityIdentifier
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }

        alert.addAction(action)
        
        DispatchQueue.main.async {
            self.viewController?.present(alert, animated: true)
        }
    }
}

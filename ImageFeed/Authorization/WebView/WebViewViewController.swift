//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 07.06.2025.
//

import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    @IBOutlet private var progressView: UIProgressView?
    @IBOutlet private var webView: WKWebView?
    
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView?.accessibilityIdentifier = "UnsplashWebView"
        
        estimatedProgressObservation = webView?.observe(
            \.estimatedProgress,
            options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self,
                       let estimatedProgess = webView?.estimatedProgress else { return }
                 presenter?.didUpdateProgressValue(estimatedProgess)
             })
        
        webView?.navigationDelegate = self
        presenter?.viewDidLoad()
    }
    
    func load(request: URLRequest) {
        webView?.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView?.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView?.isHidden = isHidden
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

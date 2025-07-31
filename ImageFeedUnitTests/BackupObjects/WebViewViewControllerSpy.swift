//
//  WebViewViewControllerSpy.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 31.07.2025.
//

@testable import ImageFeed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}

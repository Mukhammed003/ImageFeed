//
//  WebViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 31.07.2025.
//

@testable import ImageFeed
import Foundation


final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled = false
    
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
    
    
}

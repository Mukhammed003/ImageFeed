//
//  ExtensionForAnArray.swift
//  ImageFeed
//
//  Created by Muhammed Nurmukhanov on 13.07.2025.
//

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
            guard indices.contains(index) else { return self } 
            var copy = self
            copy[index] = newValue
            return copy
        }
}

//
//  StoryboardInstantiable.swift
//  BabbelGame
//
//  Created by Hakan Yildizay on 25.06.2022.
//

import Foundation
import UIKit

enum StoryboardType: String {
    case main = "Main"
}

/// This protocol makes ViewController's initialization more handy
protocol StoryboardInstantiable {
    static var storyboardType: StoryboardType { get }
    static var storyboardIdentifier: String { get }
    static func instantiate() -> Self?
}

extension StoryboardInstantiable {

    static var storyboardIdentifier: String { return String(describing: self) }

    static func instantiate() -> Self? {
        let storyboard = UIStoryboard(name: storyboardType.rawValue, bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? Self
        return viewController
    }

}

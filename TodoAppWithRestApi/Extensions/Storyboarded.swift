//
//  Storyboarded.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/18/24.
//

import Foundation
import UIKit


extension UIViewController: StoryBoarded { }
/// Storyboard 가져오기
protocol StoryBoarded {
    static func instantiate(_ storyboardName: String?) -> Self
}

extension StoryBoarded {
    
    static func instantiate(_ storyboardName: String? = nil) -> Self {
        
        let name = storyboardName ?? String(describing: self)
        
        let storyboard = UIStoryboard(name: name, bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! Self
    }
}

//
//  MainVC.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import UIKit

class MainVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(#fileID, #function, #line, "- ")
        
        self.view.backgroundColor = .systemYellow
    }


}

extension UIViewController: StoryBoarded { }

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


//
//  ReuseIdentifier.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/18/24.
//

import Foundation
import UIKit


/// reuseIdentifier 가져오기
protocol ReuseIdentifiable {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }


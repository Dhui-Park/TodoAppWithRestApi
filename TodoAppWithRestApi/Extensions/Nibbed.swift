//
//  Nibbed.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/18/24.
//

import Foundation
import UIKit


extension UITableViewCell: Nibbed { }
/// Nib File 가져오기
protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

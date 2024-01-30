//
//  UIScrollView+Reactive.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/31/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay
import RxCocoa


extension Reactive where Base: UIScrollView {
    
    /// 바닥 근처 감지
    var isNearBottom: Observable<Void> {
        
        return contentOffset
            .map { (offset: CGPoint) in
                let height = self.base.frame.size.height
                let contentYOffset = offset.y
                let distanceFromBottom = self.base.contentSize.height - contentYOffset
                return distanceFromBottom - 200 < height
            }
            .filter { $0 == true }.map { _ in }
    }
    
}

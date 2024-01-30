//
//  Optional+Ext.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/30/24.
//

import Foundation

//if case let (user?, pass?) = (user, pass) { }

extension Optional {
    init<T, U>(tuple: (T?, U?)) where Wrapped == (T, U) {
        
        switch tuple{
            case (let t?, let u?):
            self = (t, u)
        default:
            self = nil
        }
    }
}

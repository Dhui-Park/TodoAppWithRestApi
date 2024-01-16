//
//  TodosVM.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation
import Combine

class TodosVM: ObservableObject {
    
    init() {
        print(#fileID, #function, #line, "- ")
        
        
//        TodosAPI.searchTodos(searchTerm: "빡코딩") { [weak self] result in
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success(let todosResponse):
//                print(#fileID, #function, #line, "- search todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print(#fileID, #function, #line, "- failure: \(failure)")
//                self.handleError(failure)
//            }
//        }
        
        
        TodosAPI.addATodoJson(title: "사이타마후후 222", isDone: true, completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let aTodoResponse):
                print(#fileID, #function, #line, "- aTodoResponse addATodo: \(aTodoResponse)")
            case .failure(let failure):
                print(#fileID, #function, #line, "- failure: \(failure)")
                self.handleError(failure)
            }
        })
        
//        TodosAPI.fetchATodo(id: 3200, completion: { [weak self] result in
//            
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let aTodoResponse):
//                print(#fileID, #function, #line, "- aTodoResponse: \(aTodoResponse)")
//            case .failure(let failure):
//                print(#fileID, #function, #line, "- failure: \(failure)")
//                self.handleError(failure)
//            }
//        })
        
//        TodosAPI.fetchTodos { [weak self] result in
//            
//            guard let self = self else { return }
//            
//            switch result {
//            case .success(let todosResponse):
//                print(#fileID, #function, #line, "- todosResponse: \(todosResponse)")
//            case .failure(let failure):
//                print(#fileID, #function, #line, "- failure: \(failure)")
//                self.handleError(failure)
//            }
//        }
    } // init
    
    
    /// API 에러 처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        if err is TodosAPI.ApiError {
            let apiError = err as! TodosAPI.ApiError
            
            print("handleError: err : \(apiError.info)")
            
            switch apiError {
            case .noContent:
                print("컨텐츠 없음.")
            case .unauthorized:
                print("인증안됨.")
            default:
                print("default")
            }
        }
        
    }
}

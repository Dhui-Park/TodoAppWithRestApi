//
//  TodosVM.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation

class TodosVM {
    
    // 가공된 최종 데이터
    var todos: [Todo] = [] {
        didSet {
            print(#fileID, #function, #line, "- ")
            self.notifyTodosChanged?(todos)
        }
    }
    
    // 데이터 변경 이벤트
    var notifyTodosChanged: (([Todo]) -> Void)? = nil
    
    init() {
        print(#fileID, #function, #line, "- ")
        fetchTodos()
    } // init
    
    func fetchTodos(page: Int = 1) {
        print(#fileID, #function, #line, "- <#comment#>")
        
        
        // 서비스 로직
        TodosAPI.fetchTodos(page: page, completion: { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if let fetchedTodos: [Todo] = response.data {
                    self.todos = fetchedTodos
                }
            case .failure(let failure):
                print("failure: \(failure)")
            }
            
        })
    }
    
    
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

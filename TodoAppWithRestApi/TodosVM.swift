//
//  TodosVM.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxRelay

class TodosVM: ObservableObject {
    
    var disposeBag: DisposeBag = DisposeBag()
    
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
//        fetchTodos()
//        
//        TodosAPI.fetchSelectedTodos(selectedTodoIds: [4975, 4974],
//                                    completion: { result in
//            switch result {
//            case .success(let data):
//                print("TodosVM - fetchSelectedTodos: data: \(data)")
//            case .failure(let failure):
//                print("TodosVM - fetchSelectedTodos: failure: \(failure)")
//            }
//        })
        
        TodosAPI.fetchTodosWithObservable()
            .observe(on: MainScheduler.instance)
            .compactMap { $0.data } // [Todo]
            .catch { err in
                print("TodosVM - fetchTodosWithObservable: err : \(err)")
                return Observable.just([])
            } // []
            .subscribe(onNext: { [weak self] (response: [Todo]) in
                print("TodosVM - fetchTodosWithObservable: response: \(response)")
            }, onError: { [weak self] failure in
                self?.handleError(failure)
            })
            .disposed(by: disposeBag)
        
//        TodosAPI.fetchTodosWithObservableResult()
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .success(let response):
//                    print("TodosVM - fetchTodosWithObservale: response: \(response)")
//                }
//                
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteSelectedTodos(selectedTodoIds: [4983, 4979, 4978, 4977, 4976],
//                                     completion: { [weak self] deletedTodos in
//            print("TodosVM deleteSelectedTodos - deletedTodos: \(deletedTodos)")
//            
//        })
        
        
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

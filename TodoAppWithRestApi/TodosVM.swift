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
    
    
    /// 검색어
    var searchTerm: String = "" {
        didSet {
            print(#fileID, #function, #line, "- searchTerm: \(searchTerm)")
            self.searchTodos(searchTerm: searchTerm)
        }
    }
    
    
//    var errorHeard: Observable<String> = Observable.empty()
    
    // .value = stateful - keep last value
    // -> BehaviorSubject
    // x = stateless
    // -> PublishSubject
    
    //
    var errorHeardSubject: PublishSubject<String> = PublishSubject()
    
    // sub 1
    var errorMsgInfoObservable : Observable<String> = Observable.empty()
    
    // sub 2
    var errorMsgInfoSecondObservable : Observable<String> = Observable.empty()
    
    var pageInfo: Meta? = nil {
        didSet {
            print(#fileID, #function, #line, "- pageInfo: \(pageInfo)")
            
            // 다음 페이지 여부 이벤트 보내기
            self.notifyHasNextPage?(pageInfo?.hasNext() ?? true)
            
            // 현재 페이지 변경 이벤트 보내기
            self.notifyCurrentPageChanged?(currentPage)
        }
    }
    
    var selectedTodoIds: Set<Int> = [] {
        didSet {
            print(#fileID, #function, #line, "- selectedTodoIds: \(selectedTodoIds)")
            self.notifySelectedTodoIdsChanged?(Array(selectedTodoIds))
        }
    }
    
    var currentPage: Int {
        get {
            if let pageInfo = self.pageInfo,
               let currentPage = pageInfo.currentPage {
                return currentPage
            } else {
                return 1
            }
        }
    }
    
    var isLoading: Bool = false {
        didSet {
            print(#fileID, #function, #line, "- ")
            self.notifyLoadingStateChanged?(isLoading)
        }
    }
    
    // 할일 추가 이벤트
    var notifyTodoAdded: (() -> Void)? = nil
    
    // 다음 페이지 여부 이벤트
    var notifyHasNextPage: ((_ hasNext: Bool) -> Void)? = nil
    
    // 검색결과 없음 여부 이벤트
    var notifySearchDataNotFound: ((_ noContent: Bool) -> Void)? = nil

    // 리프레시 완료 이벤트
    var notifyRefreshEnded: (() -> Void)? = nil
    
    // 로딩중 여부 변경 이벤트
    var notifyLoadingStateChanged: ((_ isLoading: Bool) -> Void)? = nil
    
    // 데이터 변경 이벤트
    var notifyTodosChanged: (([Todo]) -> Void)? = nil
    
    // 현재 페이지 변경 이벤트
    var notifyCurrentPageChanged: ((Int) -> Void)? = nil
    
    // 에러 발생 이벤트
    var notifyErrorOccured: ((_ errMsg: String) -> Void)? = nil
    
    // 선택된 할일들 변경 이벤트
    var notifySelectedTodoIdsChanged: ((_ selectedIds: [Int]) -> Void)? = nil
    
    
    init() {
        print(#fileID, #function, #line, "- ")
        fetchTodos()
        
        errorMsgInfoObservable = errorHeardSubject.map{ "err: \($0)" }
        
        errorMsgInfoSecondObservable = errorHeardSubject.map{ "err second: \($0)" }
        
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
        
//        TodosAPI.fetchTodosWithObservable()
//            .observe(on: MainScheduler.instance)
//            .compactMap { $0.data } // [Todo]
//            .catch { err in
//                print("TodosVM - fetchTodosWithObservable: err : \(err)")
//                return Observable.just([])
//            } // []
//            .subscribe(onNext: { [weak self] (response: [Todo]) in
//                print("TodosVM - fetchTodosWithObservable: response: \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.fetchATodoWithObservableResultPractice(id: 4932)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .failure(let failure):
//                    self.handleError(failure)
//                case .success(let response):
//                    print("TodosVM - fetchATodoWithObservableResultPractice: response: \(response)")
//                }
//                
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.fetchATodoWithObservablePractice(id: 4932)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (response: BaseResponse<Todo>) in
//                guard let self = self else { return }
//                print("TodosVM - fetchTodosWithObservable: response: \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.searchTodosWithObservablePractice(searchTerm: "사이타마")
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] response in
//                guard let self = self else { return }
//                print("TodosVM - searchTodosWithObservable: response: \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            })
//            .disposed(by: disposeBag)
//        
//        TodosAPI.addATodoWithObservableResultPractice(title: "사이타마마마333", isDone: false)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success(let response):
//                    print("TodosVM - addATodoWithObservableResultPractice : response : \(response)")
//                case .failure(let failure):
//                    self.handleError(failure)
//                }
//            })
//            .disposed(by: disposeBag)
        
        
        
        
//        TodosAPI.editATodoJsonWithObservableResultPractice(id: 4986, title: "사이타마가 수정함")
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success(let response):
//                    print("TodosVM - editATodoJsonWithObservableResultPractice : response : \(response)")
//                case .failure(let failure):
//                    self.handleError(failure)
//                }
//            })
//            .disposed(by: disposeBag)
//        TodosAPI.editATodoWithObservablePractice(id: 4986, title: "znfkfffp")
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { response in
//                print("TodosVM - editATodoWithObservablePractice: response : \(response)")
//            }, onError: { [weak self] failure in
//                self?.handleError(failure)
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteATodoWithObservableResultPractice(id: 4986)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] result in
//                guard let self = self else { return }
//                switch result {
//                case .success(let response):
//                    print("TodosVM - deleteATodoWithObservableResultPractice : response : \(response)")
//                case .failure(let failure):
//                    self.handleError(failure)
//                }
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteATodoWithObservablePractice(id: 4987)
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { response in
//                print("TodosVM - deleteATodoWithObservablePractice: response: \(response)")
//            }, onError: { [weak self] failure in
//                guard let self = self else { return }
//                self.handleError(failure)
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.addATodoAndFetchTodosWithObservablePractice(title: "사이타마가 추가함 01111")
//            .observe(on: MainScheduler.instance)
//            .subscribe(onNext: { [weak self] (response: [Todo]) in
//                print("TodosVM - addATodoAndFetchTodosWithObservablePractice : response : \(response)")
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteSelectedTodosWithObservablePractice(selectedTodoIds: [4976, 4977, 4985])
//            .subscribe(onNext: { deletedTodos in
//                print("TodosVM - deleteSelectedTodosWithObservablePractice: deletedTodos: \(deletedTodos)")
//            }, onError: { error in
//                print("TodosVM - deleteSelectedTodosWithObservablePractice: error: \(error)")
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteSelectedTodosWithObservablePractice(selectedTodoIds: [4976, 4977, 4985])
//            .subscribe(onNext: { deletedTodos in
//                print("TodosVM - deleteSelectedTodosWithObservablePractice: deletedTodos: \(deletedTodos)")
//            }, onError: { error in
//                print("TodosVM - deleteSelectedTodosWithObservablePractice: error: \(error)")
//            })
//            .disposed(by: disposeBag)
        
//        TodosAPI.deleteSelectedTodosWithObservableMerge(selectedTodoIds: [4975, 4974, 4930, 4976, 4931])
//            .subscribe(onNext: { deletedTodo in
//                print("TodosVM - deleteSelectedTodosWithObservableMerge: deletedTodo: \(deletedTodo)")
//            }, onError: { error in
//                print("TodosVM - deleteSelectedTodosWithObservableMerge: error: \(error)")
//            })
//            .disposed(by: disposeBag)
//
        
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
    
    
    /// 선택된 할일들 처리
    /// - Parameters:
    ///   - selectedTodoid:
    ///   - isOn:
    func handleTodoSelection(_ selectedTodoid: Int, _ isOn: Bool) {
        if isOn {
            self.selectedTodoIds.insert(selectedTodoid)
        } else {
            self.selectedTodoIds.remove(selectedTodoid)
        }
    }
    
    func testAddATodo() {
        TodosAPI.addATodoJsonWithObservablePractice(title: "아쿠라", isDone: true)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                print("TodosVM - addATodoJsonWithObservablePractic : response : \($0)")
            }, onError: { [weak self] in
                dump($0)
                self?.handleError($0)
            })
            .disposed(by: disposeBag)
    }
    
    /// 할일 검색하기
    /// - Parameters:
    ///   - searchTerm: 검색어
    ///   - page: 페이지
    func searchTodos(searchTerm: String, page: Int = 1) {
        print(#fileID, #function, #line, "- <#comment#>")
        
        if searchTerm.count < 1 {
            print("검색어가 없습니다.")
            self.fetchTodos()
            return
        }
        
        if isLoading {
            print("로딩중입니다...")
            return
        }
        
        guard pageInfo?.hasNext() ?? true else {
            return print("다음 페이지 없다~")
        }
        
        self.notifySearchDataNotFound?(false)
        
        if page == 1 {
            self.todos = []
        }
        
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // 서비스 로직
            TodosAPI.searchTodos(searchTerm: searchTerm,
                                 page: page,
                                 completion: { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    
                    self.isLoading = false
                    // 페이지 갱신
                    if let fetchedTodos: [Todo] = response.data,
                       let pageInfo: Meta = response.meta {
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        self.pageInfo = pageInfo
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    self.handleError(failure)
                    self.isLoading = false
                }
                self.notifyRefreshEnded?()
                
            })
        })
        
    }
    
    func fetchRefresh() {
        print(#fileID, #function, #line, "- ")
        self.fetchTodos(page: 1)
    }
    
    /// 할일 더 가져오기
    func fetchMore() {
        print(#fileID, #function, #line, "- ")
        
        guard let pageInfo = pageInfo,
              pageInfo.hasNext(),
              !isLoading
        else {
            return print("다음 페이지가 없다.")
        }
        
        
        if searchTerm.count > 0 { // 검색어가 있으면
            self.searchTodos(searchTerm: searchTerm, page: self.currentPage + 1)
        } else {
            self.fetchTodos(page: currentPage + 1)
        }
        
    }
    
    /// 할일 추가하기
    /// - Parameter title: 할일 제목
    func addATodo(_ title: String, isDone: Bool = false) {
        print(#fileID, #function, #line, "- 할일 추가입니다 title: \(title)")
        
        if isLoading {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.addATodoAndFetchTodos(title: title, isDone: isDone, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                self.isLoading = false
                // 페이지 갱신
                
                if let fetchedTodos: [Todo] = response.data,
                   let pageInfo: Meta = response.meta {
                    self.todos = fetchedTodos
                    self.pageInfo = pageInfo
                    self.notifyTodoAdded?()
                }
            case .failure(let failure):
                print("failure: \(failure)")
                self.isLoading = false
                self.handleError(failure)
            }
        })
    }
    
    
    /// 할일 추가하기
    /// - Parameter title: 할일 제목
    func editATodo(_ id: Int, _ editedTitle: String) {
        print(#fileID, #function, #line, "- 할일 추가입니다 editedTitle: \(editedTitle)")
        
        if isLoading {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.editATodo(id: id, title: editedTitle, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                self.isLoading = false
                // 페이지 갱신
                
                if let editedTodo: Todo = response.data,
                   let editedTodoId: Int = editedTodo.id,
                   let editedIndex = self.todos.firstIndex(where: { $0.id ?? 0 == editedTodoId }){
                    
                    self.todos[editedIndex] = editedTodo
               
                }
            case .failure(let failure):
                print("failure: \(failure)")
                self.isLoading = false
                self.handleError(failure)
            }
            
        })
    }
    
    
    /// 단일 할일 삭제
    /// - Parameter id: 삭제할 아이디
    func deleteATodo(id: Int) {
        print(#fileID, #function, #line, "- id: \(id)")
        
        if isLoading {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.deleteATodo(id: id, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                
                self.isLoading = false
                // 페이지 갱신
                
                if let deletedTodo: Todo = response.data,
                   let deletedTodoId: Int = deletedTodo.id {
                    
                    // 삭제된 아이템 찾아서 그 녀석만 현재 리스트에서 지우기
                    
                    self.todos = self.todos.filter { $0.id ?? 0 != deletedTodoId }
               
                }
            case .failure(let failure):
                print("failure: \(failure)")
                self.isLoading = false
                self.handleError(failure)
            }
        })
    }
    
    /// 선택된 할일들 삭제
    /// - Parameter id: 삭제할 아이디
    func deleteSelectedTodos() {
        print(#fileID, #function, #line, "-")
        
        if self.selectedTodoIds.count < 1 {
            self.notifyErrorOccured?("선택된 할일들이 없습니다.")
            return
        }
        
        if isLoading {
            print("로딩중입니다.")
            return
        }
        
        self.isLoading = true
        
        TodosAPI.deleteSelectedTodos(selectedTodoIds: Array(self.selectedTodoIds), completion: { [weak self] deletedTodoIds in
            guard let self = self else { return }
            
            // 삭제된 아이템 찾아서 그 녀석만 현재 리스트에서 지우기
            self.todos = self.todos.filter { !deletedTodoIds.contains($0.id ?? 0) }
            
            self.selectedTodoIds = self.selectedTodoIds.filter { !deletedTodoIds.contains($0) }
            
            self.isLoading = false
        })
    }
        
        
    
    /// 할일 가져오기
    /// - Parameter page: 페이지
    func fetchTodos(page: Int = 1) {
        print(#fileID, #function, #line, "- <#comment#>")
        
        if isLoading {
            print("로딩중입니다...")
            return
        }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: {
            // 서비스 로직
            TodosAPI.fetchTodos(page: page, completion: { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    
                    // 페이지 갱신
                    
                    if let fetchedTodos: [Todo] = response.data,
                       let pageInfo: Meta = response.meta {
                        
                        self.isLoading = false
                        
                        if page == 1 {
                            self.todos = fetchedTodos
                        } else {
                            self.todos.append(contentsOf: fetchedTodos)
                        }
                        self.pageInfo = pageInfo
                        
                    }
                case .failure(let failure):
                    print("failure: \(failure)")
                    self.isLoading = false
                }
                self.notifyRefreshEnded?()
                
            })
        })
        
        
        
    }
    
    
    /// API 에러 처리
    /// - Parameter err: API 에러
    fileprivate func handleError(_ err: Error) {
        
        guard let apiError = err as? TodosAPI.ApiError else {
            print("모르는 에러입니다.")
            return
        }
        
        print("handleError: err : \(apiError.info)")
        
        switch apiError {
        case .noContent:
            print("컨텐츠 없음.")
            self.notifySearchDataNotFound?(true)
        case .unauthorized:
            print("인증안됨.")
        case .errResponseFromServer:
            print("서버에서 온 에러입니다: \(apiError.info)")
            self.notifyErrorOccured?(apiError.info)
        default:
            print("default")
        }
        
        
        
    }
}

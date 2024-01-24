//
//  TodosAPI+Closure.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/16/24.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa


extension TodosAPI {
    
    /// 모든 할일 목록 가져오기
    static func fetchTodosWithObservableResult(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, ApiError> in
                
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(urlResponse)")
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // statusCode는 200이지만 parsing한 data에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        
                        return .failure(ApiError.noContent)
                    }
                    
                    return .success(listResponse)
                } catch {
                    // decoding error
                    return .failure(ApiError.decodingError)
                }
            })
        
        
        
    }
    
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "?page=\(page)"
        
        guard let url = URL(string: urlString) else {
//            return Observable.just(.failure(ApiError.notAllowedUrl))
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(urlResponse)")
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
//                    return .failure(ApiError.unknown(nil))
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
//                    return .failure(ApiError.unauthorized)
                    throw ApiError.unauthorized
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
//                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    let todos = listResponse.data
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // statusCode는 200이지만 parsing한 data에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        
//                        return .failure(ApiError.noContent)
                        throw ApiError.noContent
                    }
                    
                    return listResponse
                } catch {
                    // decoding error
//                    return .failure(ApiError.decodingError)
                    throw ApiError.decodingError
                }
            })
    }
    
    /// 특정 할일 가져오기
    static func fetchATodoWithObservable(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                   
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    /// 할일 검색하기
    static func searchTodosWithObservable(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
//        let urlString: String = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm, "page" : "\(page)"])
        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
        
        guard let url = requestUrl else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    let todos = listResponse.data
                    print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                    
                    // statusCode는 200이지만 parsing한 data에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    
                    
                    completion(.success(listResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    
    /// 할일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func addATodoWithObservable(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        print("form: \(form.contentType)")
 
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = form.bodyData
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                   
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    
    /// 할일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithObservable(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        let requestParams: [String : Any] = ["title" : title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.jsonEncoding))
        }
        
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                   
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    
    /// 할일 수정하기 - Json
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editATodoJsonWithObservable(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        
        let requestParams: [String : Any] = ["title" : title, "is_done" : "\(isDone)"]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return completion(.failure(ApiError.jsonEncoding))
        }
        
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                   
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    /// 할일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editATodoWithObservable(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : String] = ["title" : title, "is_done" : "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)

        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                   
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    /// 할일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    static func deleteATodoWithObservable(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        
        print(#fileID, #function, #line, "- deleteATodo 호출됨 / id: \(id)")
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return completion(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        

        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, err in
            
            print(#fileID, #function, #line, "- data: \(data)")
            print(#fileID, #function, #line, "- response: \(urlResponse)")
            print(#fileID, #function, #line, "- err: \(err)")
            
            if let error = err {
                return completion(.failure(ApiError.unknown(error)))
            }
            
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                print("bad status code")
                return completion(.failure(ApiError.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 401:
                return completion(.failure(ApiError.unauthorized))
                
            case 204:
                return completion(.failure(ApiError.noContent))
            default:
                print("default")
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                return completion(.failure(ApiError.badStatus(code: httpResponse.statusCode)))
            }
            
            
            
            if let jsonData = data {
                // convert data to our swift model
                do {
                    // Json -> struct로 변경, 즉 decoding (data parsing)
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                   
                    completion(.success(baseResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
    
    /// 할일 추가 후 모든 할일 가져오기
    /// - Parameters:
    ///   - title: 추가할 할일 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 여부
    static func addATodoAndFetchTodosWithObservable(title: String,
                                      isDone: Bool = false,
                                      completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        
        self.addATodo(title: title,
                      completion: {
            switch $0 {
            case .success(_):
                self.fetchTodos(completion: {
                    switch $0 {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let failure):
                        completion(.failure(failure))
                    }
                })
            case .failure(let failure):
                completion(.failure(failure))
            }
        })
        
    }
    
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일들 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithObservable(selectedTodoIds: [Int],
                                    completion: @escaping ([Int]) -> Void) {
        
        let group: DispatchGroup = DispatchGroup()
        
        // 성공적으로 삭제가 이뤄진 녀석들
        var deletedTodoIds: [Int] = [Int]()
        
        selectedTodoIds.forEach({ aTodoId in
            // 디스패치 그룹에 넣음.
            group.enter()
            self.deleteATodo(id: aTodoId,
                             completion: { result in
                
                switch result {
                case .success(let response):
                    // 삭제된 아이디를 배열에 넣는다.
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                        print("inner deleteATodo - success: \(todoId)")
                    }
                case .failure(let failure):
                    print("inner deleteATodo - failure: \(failure)")
                }
                group.leave()
            }) // 단일 삭제 api 호출
        })
        
        // Configure a completion callback
        group.notify(queue: .main) {
            // All requests completed
            print("모든 api 완료됨.")
            completion(deletedTodoIds)
        }
        
    }
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일들 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservable(selectedTodoIds: [Int],
                                    completion: @escaping (Result<[Todo], ApiError>) -> Void) {
        
        let group: DispatchGroup = DispatchGroup()
        
        // 가져온 할일들
        var fetchedTodos: [Todo] = [Todo]()
        
        // 에러가 난 것들
        var apiErrors: [ApiError] = []
        
        // 응답 결과들
        var apiResults =  [Int : Result<BaseResponse<Todo>, ApiError>]()
        
        selectedTodoIds.forEach({ aTodoId in
            // 디스패치 그룹에 넣음.
            group.enter()
            self.fetchATodo(id: aTodoId,
                             completion: { result in
                
                switch result {
                case .success(let response):
                    // 가져온 할일을 할일 배열에 넣는다.
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                        print("inner fetchATodo - success: \(todo)")
                    }
                case .failure(let failure):
                    print("inner fetchATodo - failure: \(failure)")
                    apiErrors.append(failure)
                }
                group.leave()
            }) // 단일 할일 조회 api 호출
        })
        
        // Configure a completion callback
        group.notify(queue: .main) {
            // All requests completed
            print("모든 api 완료됨.")
            
            // 만약 에러가 있다면 첫번째 에러를 올려주기
            if !apiErrors.isEmpty {
                if let firstError = apiErrors.first {
                    completion(.failure(firstError))
                    return
                }
            }
            
            completion(.success(fetchedTodos))
        }
        
    }
    
    
}

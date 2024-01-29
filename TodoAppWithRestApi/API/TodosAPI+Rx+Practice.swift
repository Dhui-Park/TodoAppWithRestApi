//
//  TodosAPI+Rx+Practice.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/25/24.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa

struct APIErrorResponse : Decodable {
    var message: String
}

extension TodosAPI {
    
    /// 모든 할일 목록 가져오기
    static func fetchTodosWithObservableResultPractice(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
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
    
    static func fetchTodosWithObservablePractice(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
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
    static func fetchATodoWithObservableResultPractice(id: Int) -> Observable<Result<BaseResponse<Todo>, ApiError>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) -> Result<BaseResponse<Todo>, ApiError> in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                    
                case 204:
                    return .failure(ApiError.noContent)
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return .success(baseResponse)
                    } catch {
                        // decoding error
                        return .failure(ApiError.decodingError)
                    }
//                }
            }
        
        
    }
    
    static func fetchATodoWithObservablePractice(id: Int) -> Observable<BaseResponse<Todo>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
//                    return .failure(ApiError.unknown(nil))
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
//                    return .failure(ApiError.unauthorized)
                    throw ApiError.unauthorized
                    
                case 204:
//                    return .failure(ApiError.noContent)
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
//                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return baseResponse
                    } catch {
                        // decoding error
//                        return .failure(ApiError.decodingError)
                        throw ApiError.decodingError
                    }
//                }
            }
        
    }
    
    /// 할일 검색하기
    static func searchTodosWithObservablePractice(searchTerm: String, page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        // 1. URLRequest를 만든다
        
//        let urlString: String = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm, "page" : "\(page)"])
        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
        
        guard let url = requestUrl else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                    
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                        let todos = listResponse.data
                        print(#fileID, #function, #line, "- todosResponse: \(listResponse)")
                        
                        // statusCode는 200이지만 parsing한 data에 따라서 에러처리
                        guard let todos = todos,
                              !todos.isEmpty else {
                            
                            throw ApiError.noContent
                        }
                        
                           return listResponse
                    } catch {
                        // decoding error
                        throw ApiError.decodingError
                    }
//                }
            }
    }
    
    
    static func searchTodosWithObservalbeResultPractice(searchTerm: String, page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        // 1. URLRequest를 만든다
        
//        let urlString: String = baseURL + "/todos/search" + "?page=\(page)" + "&query=\(searchTerm)"
        
        let requestUrl = URL(baseUrl: baseURL + "/todos/search", queryItems: ["query" : searchTerm, "page" : "\(page)"])
        
//        var urlComponents = URLComponents(string: baseURL + "/todos/search")
//        urlComponents?.queryItems = [
//            URLQueryItem(name: "query", value: searchTerm),
//            URLQueryItem(name: "page", value: "\(page)")
//        ]
        
        guard let url = requestUrl else {
            return Observable.just(.failure(ApiError.notAllowedUrl))
        }
        
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                    
                case 204:
                    return .failure(ApiError.noContent)
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                
                
//                if let jsonData = data {
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
//                }
            }
        
    }
    
    /// 할일 추가하기
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func addATodoWithObservablePractice(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
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
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                    
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return baseResponse
                    } catch {
                        // decoding error
                        throw ApiError.decodingError
                    }
//                }
            }
    }
    
    
    /// 할일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할일 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func addATodoJsonWithObservablePractice(title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos-json"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
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
            return Observable.error(ApiError.jsonEncoding)
        }
        
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        let testUrl = urlRequest.cURL(pretty: true)
        print(#fileID, #function, #line, "- testUrl: \(testUrl)")
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                    
                case 204:
                    throw ApiError.noContent
                    
                    
                case 422:
                    let errMsgRes = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
                    dump(errMsgRes)
                    throw ApiError.errMessageFromServer(errMsgRes?.message ?? "")
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return baseResponse
                    } catch {
                        // decoding error
                        throw ApiError.decodingError
                    }
//                }
            }
        
    }
    
    
    /// 할일 수정하기 - Json
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editATodoJsonWithObservableResultPractice(id: Int, title: String, isDone: Bool = false) -> Observable<Result<BaseResponse<Todo>, ApiError>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos-json/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(ApiError.notAllowedUrl))
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
            return Observable.just(.failure(ApiError.jsonEncoding))
        }
        
        
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) in
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")
                
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                    
                case 204:
                    return .failure(ApiError.noContent)
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return .success(baseResponse)
                    } catch {
                        // decoding error
                        return .failure(ApiError.decodingError)
                    }
//                }
            }
        
        
    }
    
    /// 할일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id: 수정할 아이템 아이디
    ///   - title: 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 결과
    static func editATodoWithObservablePractice(id: Int, title: String, isDone: Bool = false) -> Observable<BaseResponse<Todo>> {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String : String] = ["title" : title, "is_done" : "\(isDone)"]
        
        urlRequest.percentEncodeParameters(parameters: requestParams)

        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (response: HTTPURLResponse, data: Data) in
                
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(response)")

                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                    
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return baseResponse
                    } catch {
                        // decoding error
                        throw ApiError.decodingError
                    }
//                }
            }
        
    }
    
    /// 할일 삭제하기 - DELETE
    /// - Parameters:
    ///   - id: 삭제할 아이템 아이디
    ///   - completion: 응답 결과
    static func deleteATodoWithObservableResultPractice(id: Int) -> Observable<Result<BaseResponse<Todo>, ApiError>> {
        
        print(#fileID, #function, #line, "- deleteATodo 호출됨 / id: \(id)")
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.just(.failure(ApiError.notAllowedUrl))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        

        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(urlResponse)")
                
                
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 401:
                    return .failure(ApiError.unauthorized)
                    
                case 204:
                    return .failure(ApiError.noContent)
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return .success(baseResponse)
                    } catch {
                        // decoding error
                        return .failure(ApiError.decodingError)
                    }
//                }
            }
        
    }
    
    static func deleteATodoWithObservablePractice(id: Int) -> Observable<BaseResponse<Todo>> {
        print(#fileID, #function, #line, "- deleteATodo 호출됨 / id: \(id)")
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos/\(id)"
        
        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notAllowedUrl)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        

        // 2. URLSession으로 API를 호출한다
        // 3. API 호출에 대한 응답을 받는다
        
        return URLSession.shared.rx.response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                
                print(#fileID, #function, #line, "- data: \(data)")
                print(#fileID, #function, #line, "- response: \(urlResponse)")
                
                
                
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    print("bad status code")
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 401:
                    throw ApiError.unauthorized
                    
                case 204:
                    throw ApiError.noContent
                default:
                    print("default")
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    throw ApiError.badStatus(code: httpResponse.statusCode)
                }
                
                
                
//                if let jsonData = data {
                    // convert data to our swift model
                    do {
                        // Json -> struct로 변경, 즉 decoding (data parsing)
                        let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                       
                        return baseResponse
                    } catch {
                        // decoding error
                        throw ApiError.decodingError
                    }
//                }
            }
    }
    
    
    /// 할일 추가 후 모든 할일 가져오기
    /// - Parameters:
    ///   - title: 추가할 할일 타이틀
    ///   - isDone: 완료 여부
    ///   - completion: 응답 여부
    static func addATodoAndFetchTodosWithObservablePractice(title: String,
                                      isDone: Bool = false) -> Observable<[Todo]> {
        
        return self.addATodoWithObservablePractice(title: title)
            .flatMapLatest { _ in
                self.fetchTodosWithObservable()
            }
            .compactMap { $0.data }
            .catch({ err in
                print("TodosAPI - carch err: \(err)")
                return Observable.just([])
            })
            .share(replay: 1)
        
    }
    
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 삭제하기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일들 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithObservablePractice(selectedTodoIds: [Int]) -> Observable<[Int]> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2. 배열로 단일 api들 호출
        
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservablePractice(id: id)
                .map { $0.data?.id } // Int?
                .catchAndReturn(nil)
        }
        
        return Observable.zip(apiCallObservables) // Observable<[Int?]>
            .map { $0.compactMap { $0 }} // Observable<[Int]>
        
    }
    
    static func deleteSelectedTodosWithObservableMerge(selectedTodoIds: [Int]) -> Observable<Int> {
        
        // 1. 매개변수 배열 -> Observable 스트림 배열
        
        // 2. 배열로 단일 api들 호출
        
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteATodoWithObservablePractice(id: id)
                .map { $0.data?.id } // Int?
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallObservables)
            .compactMap { $0 }
        
    }
    
    /// 클로져 기반 api 동시 처리
    /// 선택된 할일들 가져오기
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할일들 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservablePractice(selectedTodoIds: [Int],
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


import Foundation

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}

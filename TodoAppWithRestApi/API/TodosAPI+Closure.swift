//
//  TodosAPI+Closure.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/16/24.
//

import Foundation
import MultipartForm

extension TodosAPI {
    
    /// 모든 할일 목록 가져오기
    static func fetchTodos(page: Int = 1,
                           completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "?page=\(page)"
        
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
    
    /// 특정 할일 가져오기
    static func fetchATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
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
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
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
    static func addATodo(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
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
    static func addATodoJson(title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
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
    static func editATodoJson(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
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
    static func editATodo(id: Int, title: String, isDone: Bool = false, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
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
    static func deleteATodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
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
    static func addATodoAndFetchTodos(title: String,
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
    
}

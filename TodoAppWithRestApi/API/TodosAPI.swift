//
//  TodosAPI.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation
import MultipartForm

enum TodosAPI {
    
    static let version: String = "v2"
    
    #if DEBUG // Debug용
    static let baseURL: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/\(version)"
    #else // Release용
    static let baseURL: String = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/\(version)"
    #endif
    
    enum ApiError: Error {
        case noContent
        case decodingError
        case unauthorized
        case notAllowedUrl
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        var info: String {
            switch self {
            case .noContent: return "데이터가 없습니다."
            case .decodingError: return "디코딩 에러입니다."
            case .unauthorized: return "인증되지 않은 사용자입니다."
            case .notAllowedUrl: return "올바른 URL 형식이 아닙니다."
            case let .badStatus(code): return "코드: \(code) 에러입니다."
            case .unknown(let err): return "알 수 없는 에러입니다. \n \(err)"
            }
        }
    }
    
    /// 모든 할일 목록 가져오기
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
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
    
    
}

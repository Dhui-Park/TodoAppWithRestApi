//
//  TodosAPI.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/13/24.
//

import Foundation

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
        case badStatus(code: Int)
        case unknown(_ err: Error?)
        
        var info: String {
            switch self {
            case .noContent: return "데이터가 없습니다."
            case .decodingError: return "디코딩 에러입니다."
            case .unauthorized: return "인증되지 않은 사용자입니다."
            case let .badStatus(code): return "코드: \(code) 에러입니다."
            case .unknown(let err): return "알 수 없는 에러입니다. \n \(err)"
            }
        }
    }
    
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<TodosResponse, ApiError>) -> Void) {
        // 1. URLRequest를 만든다
        
        let urlString: String = baseURL + "/todos" + "?page=\(page)"
        
        let url: URL = URL(string: urlString)!
        
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
                    let todosResponse = try JSONDecoder().decode(TodosResponse.self, from: jsonData)
                    let todos = todosResponse.data
                    print(#fileID, #function, #line, "- todosResponse: \(todosResponse)")
                    
                    // statusCode는 200이지만 parsing한 data에 따라서 에러처리
                    guard let todos = todos,
                          !todos.isEmpty else {
                        
                        return completion(.failure(ApiError.noContent))
                    }
                    
                    
                    
                    completion(.success(todosResponse))
                } catch {
                    // decoding error
                    completion(.failure(ApiError.decodingError))
                }
            }
            
        }.resume()
        
        
    }
    
}

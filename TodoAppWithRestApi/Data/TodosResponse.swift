//
//  TodosResponse.swift
//  TodoAppWithRestApi
//
//  Created by dhui on 1/14/24.
//

import Foundation

// MARK: - TodosResponse
// Json -> struct, class : Decoding을 한다
struct TodosResponse: Decodable {
    let data: [Todo]?
    let meta: Meta?
    let message: String?
//    let hey: String
}

struct BaseListResponse<T: Codable>: Decodable {
    let data: [T]?
    let meta: Meta?
    let message: String?
//    let hey: String
}

struct BaseResponse<T: Codable>: Decodable {
    let data: T?
    let message: String?
//    let code: String?
}

// MARK: - Datum
struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
    
    
    /// 다음 페이지가 있는지 여부
    /// - Returns: 다음 페이지 존재 여부
    func hasNext() -> Bool {
        guard let current = currentPage,
              let last = lastPage else {
            print("current, last 정보 없음")
            return false
        }
        return current < last
    }
}


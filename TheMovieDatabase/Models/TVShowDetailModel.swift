//
//  TVShowModel.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 09.03.2023.
//

import Foundation

// MARK: - TVShowModel
struct TVShowDetailModel: Codable {
    let adult: Bool?
    let backdropPath: String?
    let id: Int?
    let name, originalLanguage, originalName, overview: String?
    let posterPath, type: String?
    let voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case adult
        case backdropPath = "backdrop_path"
        case id, name
        case originalLanguage = "original_language"
        case originalName = "original_name"
        case overview
        case posterPath = "poster_path"
        case type
        case voteAverage = "vote_average"
    }
}
extension TVShowDetailModel: Equatable {
    static func == (lhs: TVShowDetailModel, rhs: TVShowDetailModel) -> Bool {
        return lhs.id == rhs.id
    }
}

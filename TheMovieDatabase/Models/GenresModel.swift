//
//  GenresModel.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 30.01.2023.
//

import Foundation

struct GenresModel: Codable {
    let genres: [Genre]?
}

// MARK: - Genre
struct Genre: Codable {
    let id: Int?
    let name: String?
}

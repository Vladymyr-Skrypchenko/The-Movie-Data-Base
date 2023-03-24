//
//  File.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 12.03.2023.
//

import Foundation

class PersistenceManager {
    
    static let shared = PersistenceManager()
    
    private let favoritesKey = "favorites"
    
    private var favorites: [Movie] {
        get {
            if let data = UserDefaults.standard.data(forKey: favoritesKey),
               let favorites = try? JSONDecoder().decode([Movie].self, from: data) {
                
                return favorites
            }
            return []
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: favoritesKey)
            }
        }
    }

    func addFavorite(_ media: Movie) {
        var favoriteMedia = favorites.filter { $0.mediaType == media.mediaType }
        if !favoriteMedia.contains(where: { $0.id == media.id }) {
            favoriteMedia.append(media)
            favorites = favorites.filter { $0.mediaType != media.mediaType } + favoriteMedia
        }
    }

    func removeFavorite(_ movie: Movie) {
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            var favorites = self.favorites
            favorites.remove(at: index)
            self.favorites = favorites
        }
    }
    
    func isFavorite(_ media: Any) -> Bool {
        if let movie = media as? Movie {
            return favorites.contains(where: { $0.id == movie.id })
        }
        return false
    }

    func getFavorites() -> [Movie] {
        return favorites.reversed()
    }
}

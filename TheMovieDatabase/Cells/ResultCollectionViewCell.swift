//
//  ResultCollectionViewCell.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 03.02.2023.
//

import UIKit
import Alamofire

class ResultCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var ratingMovieLbl: UILabel!
    
    var movies: Movie? {
        didSet {
            ratingMovieLbl.text = movies?.voteAverage?.description
            let urlImage = "https://image.tmdb.org/t/p/w500" + (self.movies?.posterPath!)!
            AF.request (urlImage).response { response in
                guard let data = response.data, let image = UIImage (data: data) else { return }
                self.movieImageView.image = image
            }
        }
    }
}



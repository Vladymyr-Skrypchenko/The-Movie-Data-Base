//
//  DetailsViewController.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 10.02.2023.
//

import UIKit
import youtube_ios_player_helper_swift
import Alamofire

class DetailViewController: UIViewController {
   
    
    var tvShow: TVShowDetailModel?
    var movieDetailView: MovieDetailModel?
    var tvDetailView: TVShowDetailModel?
    var movie: Movie!
    var tv: Movie!
    var video: Results!
    
    
  
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var detailRatingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var trailerPlayerView: YTPlayerView!
    //YTPlayerView!
    
    //MARK: -  Video https://api.themoviedb.org/3/movie/10759/videos?api_key=ed303f39f93f7741fce35dfeb5e6c02f
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDetailMovie()
        updateFavoriteButtonTitle()
        favoriteButton.isEnabled = true
        loadVideo()
    }
   
    override func viewDidDisappear(_ animated: Bool) {
       // trailerPlayerView.stopVideo()
    }
    
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        guard let movie = movie ?? tv as? Movie ?? tv as? Movie else { return }
        
        if PersistenceManager.shared.isFavorite(movie) {
            PersistenceManager.shared.removeFavorite(movie)
        } else {
            PersistenceManager.shared.addFavorite(movie)
        }
        
        updateFavoriteButtonTitle()
        
        let message = PersistenceManager.shared.isFavorite(movie) ? "Added to favorites" : "Removed from favorites"
        let alertController = UIAlertController(title: message, message: "To view your favorites, go to the Favorites section", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func updateFavoriteButtonTitle() {
        guard let movie = movie ?? tv as? Movie ?? tv as? Movie else { return }
        let isFavorite = PersistenceManager.shared.isFavorite(movie)
        
        if isFavorite {
            favoriteButton.setImage(UIImage(named: "favoritePressed"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
        }
    }
    
    func loadDetailMovie() {
        let group = DispatchGroup()
        
        if let movie = self.movie {
            group.enter()
            AF.request("https://api.themoviedb.org/3/movie/\(movie.id!)?api_key=ed303f39f93f7741fce35dfeb5e6c02f", method: .get).responseDecodable(of: MovieDetailModel.self) { [self] (response) in
                switch response.result {
                case .success(let detailMovieModel):
                    self.movieDetailView = detailMovieModel
                    
                    let detailUrlImage = "https://image.tmdb.org/t/p/w500" + (self.movieDetailView?.posterPath ?? "")
                    AF.request(detailUrlImage).response { response in
                        guard let data = response.data, let image = UIImage (data: data) else { return }
                        self.posterView.image = image
                    }
                    self.titleLabel.text = self.movieDetailView?.title
                    self.detailRatingLabel.text = movieDetailView?.voteAverage?.description
                    overviewTextView.text = self.movieDetailView?.overview
                    
                    group.leave()
                case .failure(let error):
                    print(error)
                }
            }
        } else if let tv = self.tv {
            group.enter()
            AF.request("https://api.themoviedb.org/3/tv/\(tv.id!)?api_key=ed303f39f93f7741fce35dfeb5e6c02f", method: .get).responseDecodable(of: TVShowDetailModel.self) { [self] (response) in
                switch response.result {
                case .success(let detailTvModel):
                    self.tvDetailView = detailTvModel
                    
                    let detailUrlImage = "https://image.tmdb.org/t/p/w500" + (self.tvDetailView?.posterPath ?? "")
                    AF.request(detailUrlImage).response { response in
                        guard let data = response.data, let image = UIImage (data: data) else { return }
                        self.posterView.image = image
                    }
                    self.titleLabel.text = self.tvDetailView?.name
                    self.detailRatingLabel.text = tvDetailView?.voteAverage?.description
                    overviewTextView.text = self.tvDetailView?.overview
                    
                    group.leave()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    func loadVideo() {
        guard let id = movie?.id ?? tv?.id else {
            return
        }
        
        let urlString = "https://api.themoviedb.org/3/\(movie != nil ? "movie" : "tv")/\(id)/videos?api_key=ed303f39f93f7741fce35dfeb5e6c02f"
        
        AF.request(urlString).responseDecodable(of: VideoResult.self) { [weak self] response in
            guard let self = self else {
                return
            }
            
            switch response.result {
            case .success(let videoResult):
                if let trailerKey = videoResult.results?.first(where: { $0.site == "YouTube" })?.key {
                    // Load the video into the player
                    DispatchQueue.main.async {
                        self.trailerPlayerView.load(videoId: trailerKey)
                    }
                } else {
                    // добавить заглушку
                    let placeholderImage = UIImage(named: "placeholderYoutube")
                    let placeholderImageView = UIImageView(image: placeholderImage)
                    placeholderImageView.contentMode = .scaleAspectFit
                    self.trailerPlayerView.addSubview(placeholderImageView)
                    placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        placeholderImageView.topAnchor.constraint(equalTo: self.trailerPlayerView.topAnchor),
                        placeholderImageView.bottomAnchor.constraint(equalTo: self.trailerPlayerView.bottomAnchor),
                        placeholderImageView.leadingAnchor.constraint(equalTo: self.trailerPlayerView.leadingAnchor),
                        placeholderImageView.trailingAnchor.constraint(equalTo: self.trailerPlayerView.trailingAnchor)
                    ])
                    // Output status to console
                    print("No video found")
                }
                    // Output status to console
     
            case .failure(let error):
                // Output status to console
                print("Video loading failed with error: \(error.localizedDescription)")
            }
        }
    }

}


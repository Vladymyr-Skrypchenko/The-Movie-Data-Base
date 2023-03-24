//
//  ViewController.swift
//  TheMovieDatabase
//
//  Created by Владимир Скрипченко on 01.01.2023.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var arrayOfMovies: [Movie] = []
    var arrayOfTv: [Movie] = []
    var arrayOfGenres: [Genre] = []
    var arrayOfGenresTv: [Genre] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self

        loadData()
    }
    
    //MARK: -  SigmendetControll
    
    
    @IBAction func didChangeSegment(_ sender: Any) {
        tableView.reloadData()
    }
    
    func loadData() {
        let group = DispatchGroup()
        
        group.enter()
        AF.request("https://api.themoviedb.org/3/genre/tv/list?api_key=ed303f39f93f7741fce35dfeb5e6c02f", method: .get).responseDecodable(of: GenresModel.self) { (response) in
            switch response.result {
            case .success(let genresTv):
                self.arrayOfGenresTv = genresTv.genres!
                group.leave()
                
            case .failure(let error):
                print(error)
                
            }
        }
        group.enter()
        AF.request("https://api.themoviedb.org/3/trending/tv/week?api_key=ed303f39f93f7741fce35dfeb5e6c02f", method: .get).responseDecodable(of: MoviesModel.self) { (response) in
            switch response.result {
            case .success(let model):
                self.arrayOfTv = model.results ?? []
                group.leave()
                
            case .failure(let error):
                print(error)
            }
        }
        group.enter()

        AF.request("https://api.themoviedb.org/3/trending/movie/week?api_key=ed303f39f93f7741fce35dfeb5e6c02f", method: .get).responseDecodable(of: MoviesModel.self) { (response) in
            switch response.result {
            case .success(let model):
                self.arrayOfMovies = model.results ?? []
                group.leave()
                
            case .failure(let error):
                print(error)
            }
        }
        group.enter()
        AF.request("https://api.themoviedb.org/3/genre/movie/list?api_key=ed303f39f93f7741fce35dfeb5e6c02f", method: .get).responseDecodable(of: GenresModel.self) { (response) in
            switch response.result {
            case .success(let genres):
                self.arrayOfGenres = genres.genres!
                group.leave()
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main, execute: {
            self.filterGenres()
            self.tableView.reloadData()
        })
        
    }
    func filterGenres() {
        var arrayMoviesGenres: [Genre] = []
        var arrayTvGenres: [Genre] = []
        for genre in self.arrayOfGenres {
            let moviesCount = arrayOfMovies.filter({$0.genreIDS?.contains(genre.id!) == true}).count
            if moviesCount > 0 {
                arrayMoviesGenres.append(genre)
            }
        }
        for genre in self.arrayOfGenresTv {
            let moviesCount = arrayOfTv.filter({$0.genreIDS?.contains(genre.id!) == true}).count
            if moviesCount > 0 {
                arrayTvGenres.append(genre)
            }
        }
        arrayOfGenres = arrayMoviesGenres
        arrayOfGenresTv = arrayTvGenres
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return arrayOfGenres.count
        case 1:
            return arrayOfGenresTv.count
        default:
            break
        }
        return 0
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ResultsTableViewCell") as? ResultsTableViewCell else {
            return UITableViewCell() }
        cell.delegate = self
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            let genre = arrayOfGenres[indexPath.row]
            cell.movies = arrayOfMovies.filter({$0.genreIDS?.contains(genre.id!) == true})
            cell.genre = genre
        case 1:
            let genreTv = arrayOfGenresTv[indexPath.row]
            cell.movies = arrayOfTv.filter({$0.genreIDS?.contains(genreTv.id!) == true})
            cell.genre = genreTv
        default:
            break
        }
        return cell
    }
}

extension ViewController: ResultsTableViewCellDelegate {
    
    //MARK: -  and open detail Controller
    func didCellPressed(cell: ResultsTableViewCell, media: Movie) {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let viewController = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
         
         if segmentedControl.selectedSegmentIndex == 0 {
             viewController.movie = media
         } else {
             viewController.tv = media
         }
         
         navigationController?.pushViewController(viewController, animated: true)
     }
}


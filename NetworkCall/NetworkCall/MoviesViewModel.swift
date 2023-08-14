//
//  MoviesViewModel.swift
//  NetworkCall
//
//  Created by Mateusz Chojnacki on 11/08/2023.
//

import Combine
import Foundation

final class MoviesViewModel: ObservableObject {
    @Published private var upcommingMovies: [Movie] = []
    @Published private var searchResults: [Movie] = []
    @Published var serachQuery: String = ""
    
    var movies: [Movie] {
        if serachQuery.isEmpty {
            return upcommingMovies
        } else {
            return searchResults
        }
    }
    
    var cancelables = Set<AnyCancellable>()
    
    init() {
        $serachQuery
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .map { searchQuery in
                searchMovies(for: searchQuery)
                    .replaceError(with: MovieResponse(results: []))
            }
            .switchToLatest()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .assign(to: &$searchResults )
        
    }
    
    func fetchInitialData() {
        fetchMovies()
            .map(\.results)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] movies in
                self?.upcommingMovies = movies
            }
            .store(in: &cancelables)

    }
}

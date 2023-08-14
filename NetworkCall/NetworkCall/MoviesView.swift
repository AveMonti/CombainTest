//
//  ContentView.swift
//  NetworkCall
//
//  Created by Mateusz Chojnacki on 11/08/2023.
//

import SwiftUI

struct MoviesView: View {
    
    @StateObject var viewModel = MoviesViewModel()
    
    var body: some View {
        List(viewModel.movies) { movie in
                HStack {
                    AsyncImage(url: movie.posterURL) { poster in
                        poster
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(movie.title)
                            .font(.headline)
                        Text(movie.overview)
                            .font(.caption)
                            .lineLimit(3)
                    }
                }
        }
        .navigationTitle("Upcomming movies")
        .searchable(text: $viewModel.serachQuery)
        .onAppear {
            viewModel.fetchInitialData()
        }
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView()
    }
}

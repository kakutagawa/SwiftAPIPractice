//
//  ContentView.swift
//  SwiftAPIPractice
//
//  Created by 芥川浩平 on 2023/12/09.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pokemonAPI = PokemonAPI()

    var body: some View {
        ScrollView {
            VStack {
                ForEach(pokemonAPI.pokemons, id: \.id) { pokemon in
                    HStack {
                        VStack {
                            Text("図鑑番号：No\(pokemon.id.description)")
                            Text(pokemon.name)
                        }
                        AsyncImage(url: URL(string: pokemon.sprites.other.officialArtwork.frontDefault)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    Divider()
                }
            }
        }
        .onAppear {
            Task {
                await pokemonAPI.fetchall()
            }
        }
    }
}

#Preview {
    ContentView()
}

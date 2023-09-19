//
//  PokedexCollectionViewCellViewModel.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import Foundation

struct PokedexCollectionViewCellViewModel: Hashable, Equatable {
    
    public let pokemonId: Int
    public let pokemonName: String
    public let pokemonImageURL: URL?
    
    // MARK: Init
    
    init(
        pokemonId: Int,
        pokemonName: String,
        pokemonImageURL: URL?
    ) {
        self.pokemonId = pokemonId
        self.pokemonName = pokemonName.firstLetterCapitalized()
        self.pokemonImageURL = pokemonImageURL
    }
    
    // MARK: Hashable
    
    static func == (
        lhs: PokedexCollectionViewCellViewModel,
        rhs: PokedexCollectionViewCellViewModel
    ) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(pokemonId)
    }
}

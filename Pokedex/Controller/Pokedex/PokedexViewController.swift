//
//  PokedexViewController.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import UIKit

class PokedexViewController: UIViewController {
    
    private let pokedexListView = PokedexListView()
    
    public private(set) var currentPokemonCell: PokedexCollectionViewCell?
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pokédex"
        setUpView()
    }
    
    // MARK: Private

    private func setUpView() {
        pokedexListView.delegate = self
        view.addSubview(pokedexListView)
        NSLayoutConstraint.activate([
            pokedexListView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pokedexListView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            pokedexListView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            pokedexListView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: List View Delegate

extension PokedexViewController: PokedexListViewDelegate {
    @MainActor func pokePodedexListView(
        _ pokedexListView: PokedexListView,
        didSelectPokemon pokemon: Pokemon,
        cell: PokedexCollectionViewCell
    ) {
        currentPokemonCell = cell
        guard let image = currentPokemonCell?.pokemonSpriteImage.image else { return }
        let vc = PokemonViewController(pokemonImage: image)
        navigationController?.delegate = PokeTransitionManager.shared
        navigationController?.pushViewController(vc, animated: true)
    }
}

//
//  PokemonViewController.swift
//  Pokedex
//
//  Created by Carson Gross on 9/17/23.
//

import UIKit

class PokemonViewController: UIViewController {
    
    // MARK: Properties

    public private(set) var pokemonView = PokemonView()
    
    private let pokemon: Pokemon
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Init
    
    init(pokemon: Pokemon) {
        self.pokemon = pokemon
        super.init(nibName: nil, bundle: nil)
    }
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        title = pokemon.name.firstLetterCapitalized()
        view.backgroundColor = .systemBackground
        setUpView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: Private
    
    private func setUpView() {
        let viewModel = PokemonViewViewModel(
            pokemonName: pokemon.name,
            pokemonId: pokemon.id,
            pokemonSpriteURL: URL(string: pokemon.sprites.versions.generationV.blackWhite.animated?.front_default ?? pokemon.sprites.front_default ?? "")
        )
        pokemonView.configure(with: viewModel)
        view.addSubview(pokemonView)
        NSLayoutConstraint.activate([
            pokemonView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pokemonView.rightAnchor.constraint(equalTo: view.rightAnchor),
            pokemonView.topAnchor.constraint(equalTo: view.topAnchor),
            pokemonView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

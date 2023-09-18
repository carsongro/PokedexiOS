//
//  PokemonViewController.swift
//  Pokedex
//
//  Created by Carson Gross on 9/17/23.
//

import UIKit

class PokemonViewController: UIViewController {
    
    // MARK: Properties
    
    public private(set) var pokemonSpriteImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
        
    private var pokemonImage: UIImage
    
    init(
        pokemonImage: UIImage
    ) {
        self.pokemonImage = pokemonImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.backgroundColor = .systemBackground
        pokemonSpriteImage.image = pokemonImage
        view.addSubviews(pokemonSpriteImage)
        addConstraints()
    }
    
    // MARK: Private
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            pokemonSpriteImage.leftAnchor.constraint(equalTo: view.leftAnchor),
            pokemonSpriteImage.rightAnchor.constraint(equalTo: view.rightAnchor),
            pokemonSpriteImage.topAnchor.constraint(equalTo: view.topAnchor),
            pokemonSpriteImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

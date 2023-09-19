//
//  PokemonView.swift
//  Pokedex
//
//  Created by Carson Gross on 9/17/23.
//

import UIKit

class PokemonView: UIView {
    
    // MARK: Properties
    
    public private(set) var pokemonSpriteImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var pokemonIdLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)
        return label
    }()
    
    private var pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .semibold)
        return label
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(
            pokemonSpriteImageView,
            pokemonIdLabel,
            pokemonNameLabel
        )
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            pokemonSpriteImageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            pokemonSpriteImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            pokemonSpriteImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: 10),
            pokemonSpriteImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.25),
            
            pokemonIdLabel.topAnchor.constraint(equalTo: pokemonSpriteImageView.bottomAnchor, constant: 10),
            pokemonIdLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            pokemonIdLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10),
            
            pokemonNameLabel.topAnchor.constraint(equalTo: pokemonIdLabel.bottomAnchor, constant: 10),
            pokemonNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            pokemonNameLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 10),
        ])
    }
    
    // MARK: Public
    
    public func configure(with viewModel: PokemonViewViewModel) {
        pokemonIdLabel.text = String(viewModel.pokemonId)
        pokemonNameLabel.text = viewModel.pokemonName
        pokemonSpriteImageView.sd_setImage(with: viewModel.pokemonSpriteURL)
    }
    
}

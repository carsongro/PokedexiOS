//
//  PokedexCollectionViewCell.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import UIKit
import SDWebImage

class PokedexCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    static let cellIdentifier = "PokedexCollectionViewCell"
    
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
    
    public private(set) var pokemonSpriteImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        addSubviews(
            pokemonSpriteImage,
            pokemonNameLabel,
            pokemonIdLabel
        )
        addConstraints()
        setUpLayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    
    override func prepareForReuse() {
        pokemonIdLabel.text = nil
        pokemonNameLabel.text = nil
        pokemonSpriteImage.image = nil
    }
    
    // MARK: Public
    
    public func configure(with viewModel: PokedexCollectionViewCellViewModel) {
        pokemonIdLabel.text = String(viewModel.pokemonId)
        pokemonNameLabel.text = viewModel.pokemonName
        pokemonSpriteImage.sd_setImage(with: viewModel.pokemonImageURL)
    }
    
    // MARK: Private
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            pokemonSpriteImage.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.85),
            pokemonSpriteImage.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.85),
            pokemonSpriteImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            pokemonSpriteImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            pokemonNameLabel.leftAnchor.constraint(equalTo: pokemonSpriteImage.rightAnchor, constant: 10),
            pokemonNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            pokemonIdLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            pokemonIdLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setUpLayer() {
        contentView.layer.cornerRadius = 8
        contentView.layer.shadowColor = UIColor.label.cgColor
        contentView.layer.cornerRadius = 4
        contentView.layer.shadowOffset = CGSize(width: -4, height: 4)
        contentView.layer.shadowOpacity = 0.3
    }
}

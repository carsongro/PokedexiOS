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
    private var currentPokemonCellSnapshot: UIView?
    var animator: Animator?
    
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
        currentPokemonCellSnapshot = currentPokemonCell?.pokemonSpriteImageView.snapshotView(afterScreenUpdates: false)
        let vc = PokemonViewController(pokemon: pokemon)
        vc.transitioningDelegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}

extension PokedexViewController: UIViewControllerTransitioningDelegate {
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard
            let secondVC = presented as? PokemonViewController,
            let selectedCellImageViewSnapshot = currentPokemonCellSnapshot
        else {
            return nil
        }

        animator = Animator(
            type: .present,
            firstVC: self,
            secondVC: secondVC,
            selectedCellImageViewSnapshot: selectedCellImageViewSnapshot
        )
        return animator
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let secondVC = dismissed as? PokemonViewController,
              let selectedCellImageViewSnapshot = currentPokemonCellSnapshot else {
            return nil
        }

        animator = Animator(
            type: .dismiss,
            firstVC: self,
            secondVC: secondVC,
            selectedCellImageViewSnapshot: selectedCellImageViewSnapshot
        )

        return animator
    }
}

//
//  PokeTransitionManager.swift
//  Pokedex
//
//  Created by Carson Gross on 9/17/23.
//

import UIKit

/// Object to create smooth transitions
final class PokeTransitionManager: NSObject {
    
    // MARK: Properties
    
    static let shared = PokeTransitionManager()
    
    private let duration: TimeInterval
    private var operation = UINavigationController.Operation.push
    
    init(
        duration: TimeInterval = 0.25
    ) {
        self.duration = duration
    }
    
    // MARK: Methods
    
    @MainActor
    private func presentVCAnimated(
        _ toVC: PokemonViewController,
        from fromVC: PokedexViewController,
        transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let pokemonCell = fromVC.currentPokemonCell,
              let pokemonSpriteImageView = fromVC.currentPokemonCell?.pokemonSpriteImageView else {
            transitionContext.completeTransition(false)
            return
        }

        toVC.view.layoutIfNeeded()

        let containerView = transitionContext.containerView

        let snapshotContentView = UIView()
        snapshotContentView.backgroundColor = .systemBackground
        snapshotContentView.frame = containerView.convert(
            pokemonCell.contentView.frame,
            from: pokemonCell
        )
        
        let snapshotPokemonSpriteImageView = UIImageView()
        snapshotPokemonSpriteImageView.contentMode = .scaleAspectFit
        snapshotPokemonSpriteImageView.image = pokemonSpriteImageView.image
        snapshotPokemonSpriteImageView.frame = containerView.convert(
            pokemonSpriteImageView.frame,
            from: pokemonCell
        )

        containerView.addSubviews(
            toVC.view,
            snapshotContentView,
            snapshotPokemonSpriteImageView
        )

        toVC.view.isHidden = true

        UIView.animate(
            withDuration: duration
        ) {
            snapshotContentView.frame = containerView.convert(
                toVC.view.frame,
                from: toVC.view
            )

            snapshotPokemonSpriteImageView.frame = containerView.convert(
                toVC.pokemonView.pokemonSpriteImageView.frame,
                from: toVC.pokemonView.pokemonSpriteImageView
            )
        } completion: { _ in
            toVC.view.isHidden = false
            snapshotPokemonSpriteImageView.removeFromSuperview()
            snapshotContentView.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
    @MainActor
    private func dismissVCAnimated(
        _ fromVC: PokemonViewController,
        to toVC: PokedexViewController,
        transitionContext: UIViewControllerContextTransitioning
    ) {
        // Use UIViewControllerInteractiveTransitioning
    }
}

// MARK: Transitioning Delegate

extension PokeTransitionManager: UIViewControllerAnimatedTransitioning {
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        duration
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(false)
            return
        }
        
        switch operation {
        case .push:
            guard let pokedexVC = fromVC as? PokedexViewController,
                  let pokemonVC = toVC as? PokemonViewController else {
                return
            }
            
            presentVCAnimated(pokemonVC,
                      from: pokedexVC,
                      transitionContext: transitionContext)
        case .pop:
            guard let pokemonVC = fromVC as? PokemonViewController,
                  let pokedexVC = toVC as? PokedexViewController else {
                return
            }
            
            dismissVCAnimated(pokemonVC,
                      to: pokedexVC,
                      transitionContext: transitionContext)
        default:
            break
        }
    }
}

// MARK: NavigationController

extension PokeTransitionManager: UINavigationControllerDelegate {
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController, to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        self.operation = operation
        
        // TODO: Handle popping
        switch operation {
        case .push:
            return self
        default:
            return nil
        }
    }
}

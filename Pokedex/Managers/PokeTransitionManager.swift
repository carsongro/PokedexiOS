//
//  PokeTransitionManager.swift
//  Pokedex
//
//  Created by Carson Gross on 9/17/23.
//

import UIKit

final class PokeTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: Properties
    
    static let shared = PokeTransitionManager()
    
    private let duration: TimeInterval
    private var operation = UINavigationController.Operation.push
    
    init(
        duration: TimeInterval = 0.25
    ) {
        self.duration = duration
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PokedexViewController,
              let toVC = transitionContext.viewController(forKey: .to) as? PokemonViewController,
              let pokemonCell = fromVC.currentPokemonCell,
              let pokemonSpriteImageView = fromVC.currentPokemonCell?.pokemonSpriteImage else {
            transitionContext.completeTransition(false)
            return
        }
        
        toVC.view.layoutIfNeeded()
        
        let containerView = transitionContext.containerView
        
        let snapshotContentView = UIView()
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
        
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: .easeInOut
        ) {
            snapshotContentView.frame = containerView.convert(
                toVC.view.frame,
                from: toVC.view
            )
            snapshotPokemonSpriteImageView.frame = containerView.convert(
                toVC.pokemonSpriteImage.frame,
                from: toVC.pokemonSpriteImage
            )
        }
        
        animator.addCompletion { position in
            toVC.view.isHidden = false
            snapshotPokemonSpriteImageView.removeFromSuperview()
            snapshotContentView.removeFromSuperview()
            transitionContext.completeTransition(position == .end)
        }
        
        animator.startAnimation()
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

        if operation == .push {
            return self
        }
        
        return nil
    }
}

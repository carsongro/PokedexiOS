//
//  Animator.swift
//  Pokedex
//
//  Created by Carson Gross on 9/18/23.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    
    static let duration: TimeInterval = 0.25
    
    private let type: PresentationType
    private let firstVC: PokedexViewController
    private let secondVC: PokemonViewController
    private var selectedCellImageViewSnapshot: UIView
    private let cellImageViewRect: CGRect
    
    init?(
        type: PresentationType,
        firstVC: PokedexViewController,
        secondVC: PokemonViewController,
        selectedCellImageViewSnapshot: UIView
    ) {
        self.type = type
        self.firstVC = firstVC
        self.secondVC = secondVC
        self.selectedCellImageViewSnapshot = selectedCellImageViewSnapshot
        
        guard let window = firstVC.view.window ?? secondVC.view.window,
              let selectedCell = firstVC.currentPokemonCell else {
            return nil
        }
        
        self.cellImageViewRect = selectedCell.pokemonSpriteImageView.convert(
            selectedCell.pokemonSpriteImageView.bounds,
            to: window
        )
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        Self.duration
    }
    
    func animateTransition(
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        let containerView = transitionContext.containerView
        let isPresenting = type.isPresenting
        
        guard let toView = secondVC.view else {
            transitionContext.completeTransition(false)
            return
        }
        
        toView.alpha = 0
        containerView.addSubview(toView)
        
        guard let selectedCell = firstVC.currentPokemonCell,
              let window = firstVC.view.window ?? secondVC.view.window,
              let cellImageSnapshot = selectedCell.pokemonSpriteImageView.snapshotView(afterScreenUpdates: true), // Initial Cell image
              let controllerImageSnapshot = secondVC.pokemonView.pokemonSpriteImageView.snapshotView(afterScreenUpdates: true) // Ending positiong image
        else {
            transitionContext.completeTransition(true)
            return
        }
        
        let imageViewSnapshot = isPresenting ? cellImageSnapshot : controllerImageSnapshot
        
        if !isPresenting {
            if let background = firstVC.view.snapshotView(afterScreenUpdates: true) {
                containerView.addSubview(background)
            }
        }
        
        let controllerImageViewRect = secondVC.pokemonView.pokemonSpriteImageView.convert(controllerImageSnapshot.bounds, to: window)
        
        imageViewSnapshot.contentMode = .scaleAspectFit
        imageViewSnapshot.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
        
        let snapshotContentView = UIView()
        snapshotContentView.backgroundColor = isPresenting ? selectedCell.backgroundColor : secondVC.view.backgroundColor
        snapshotContentView.frame = containerView.convert(
            isPresenting ? selectedCell.contentView.frame : secondVC.view.frame,
            from: isPresenting ? selectedCell.contentView : secondVC.view
        )
        
        containerView.addSubviews(snapshotContentView, imageViewSnapshot)
        
        UIView.animate(withDuration: Self.duration) {
            snapshotContentView.frame = containerView.convert(
                isPresenting ? self.firstVC.view.frame : selectedCell.contentView.frame,
                from: isPresenting ? self.firstVC.view : selectedCell.contentView
            )
            snapshotContentView.backgroundColor = isPresenting ? self.secondVC.view.backgroundColor : selectedCell.backgroundColor
            imageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
        } completion: { _ in
            snapshotContentView.removeFromSuperview()
            imageViewSnapshot.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        }
    }
}

enum PresentationType {
    case present
    case dismiss
    
    var isPresenting: Bool {
        self == .present
    }
}

//let containerView = transitionContext.containerView
//let isPresenting = type.isPresenting
//
//guard let toView = secondVC.view else {
//    transitionContext.completeTransition(false)
//    return
//}
//
//toView.alpha = 0
//containerView.addSubview(toView)
//
//guard let selectedCell = firstVC.currentPokemonCell,
//      let window = firstVC.view.window ?? secondVC.view.window,
//      let cellImageSnapshot = selectedCell.pokemonSpriteImageView.snapshotView(afterScreenUpdates: true), // Initial Cell image
//      let controllerImageSnapshot = secondVC.pokemonView.pokemonSpriteImageView.snapshotView(afterScreenUpdates: true) // Ending positiong image
//else {
//    transitionContext.completeTransition(true)
//    return
//}
//
//let imageViewSnapshot = isPresenting ? cellImageSnapshot : controllerImageSnapshot
//
//if !isPresenting {
//    if let background = firstVC.view.snapshotView(afterScreenUpdates: true) {
//        containerView.addSubview(background)
//    }
//}
//
//let controllerImageViewRect = secondVC.pokemonView.pokemonSpriteImageView.convert(controllerImageSnapshot.bounds, to: window)
//
//imageViewSnapshot.contentMode = .scaleAspectFit
//imageViewSnapshot.frame = isPresenting ? cellImageViewRect : controllerImageViewRect
//
//let snapshotContentView = UIView()
//snapshotContentView.backgroundColor = isPresenting ? selectedCell.backgroundColor : secondVC.view.backgroundColor
//snapshotContentView.frame = containerView.convert(
//    isPresenting ? selectedCell.contentView.frame : secondVC.view.frame,
//    from: isPresenting ? selectedCell.contentView : secondVC.view
//)
//
//containerView.addSubviews(snapshotContentView, imageViewSnapshot)
//
//UIView.animate(withDuration: Self.duration) {
//    snapshotContentView.frame = containerView.convert(
//        isPresenting ? self.firstVC.view.frame : selectedCell.contentView.frame,
//        from: isPresenting ? self.firstVC.view : selectedCell.contentView
//    )
//    snapshotContentView.backgroundColor = isPresenting ? self.secondVC.view.backgroundColor : selectedCell.backgroundColor
//    imageViewSnapshot.frame = isPresenting ? controllerImageViewRect : self.cellImageViewRect
//} completion: { _ in
//    snapshotContentView.removeFromSuperview()
//    imageViewSnapshot.removeFromSuperview()
//    toView.alpha = 1
//    transitionContext.completeTransition(true)
//}

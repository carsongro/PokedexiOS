//
//  PokeTabBarController.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import UIKit

class PokeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTabs()
    }
    
    private func setUpTabs() {
        let pokedexVC = PokedexViewController()
        let itemsVC = ItemsViewController()
        
        pokedexVC.navigationItem.largeTitleDisplayMode = .automatic
        itemsVC.navigationItem.largeTitleDisplayMode = .automatic
        
        let nav1 = UINavigationController(rootViewController: pokedexVC)
        let nav2 = UINavigationController(rootViewController: itemsVC)
        
        nav1.tabBarItem = UITabBarItem(
            title: "Pokédex",
            image: UIImage(systemName: "list.bullet"),
            tag: 1
        )
        
        nav2.tabBarItem = UITabBarItem(
            title: "Items",
            image: UIImage(systemName: "backpack"),
            tag: 2
        )
        
        for nav in [nav1, nav2] {
            nav.navigationBar.prefersLargeTitles = true
        }
        
        setViewControllers(
            [nav1, nav2],
            animated: true
        )
    }
}

//
//  PokedexListView.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import UIKit

protocol PokedexListViewDelegate: AnyObject {
    func pokePodedexListView(
        _ pokedexListView: PokedexListView,
        didSelectPokemon pokemon: Pokemon,
        cell: PokedexCollectionViewCell
    ) async
}

class PokedexListView: UIView {
    
    // MARK: Properties
    
    public weak var delegate: PokedexListViewDelegate?
    
    private var viewModel = PokedexListViewViewModel()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        collectionView.alpha = 0
        collectionView.register(
            PokedexCollectionViewCell.self,
            forCellWithReuseIdentifier: PokedexCollectionViewCell.cellIdentifier
        )
        collectionView.register(
            PokeFooterLoadingCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: PokeFooterLoadingCollectionReusableView.identifier
        )
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<PokedexListViewViewModel.PokedexSection, PokedexCollectionViewCellViewModel>?

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        addSubviews(collectionView, spinner)
        
        addConstraints()
        
        viewModel.delegate = self
        viewModel.fetchPokemon()
        setUpCollectionView()
        setUpDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Private
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 100),
            spinner.heightAnchor.constraint(equalToConstant: 100),
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setUpCollectionView() {
        collectionView.delegate = viewModel
    }
    
    private func setUpDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            guard let self,
                  let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: PokedexCollectionViewCell.cellIdentifier,
                    for: indexPath
                  ) as? PokedexCollectionViewCell else {
                fatalError("Error dequeuing cell")
            }
            
            let cellViewModel = self.viewModel.cellViewModels[indexPath.row]
            cell.configure(with: cellViewModel)
            return cell
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else {
                return nil
            }
            
            guard let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PokeFooterLoadingCollectionReusableView.identifier,
                for: indexPath) as? PokeFooterLoadingCollectionReusableView else {
                return nil
            }
            
            footer.startAnimating()
            return footer
        }
    }
    
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<PokedexListViewViewModel.PokedexSection, PokedexCollectionViewCellViewModel>()
        
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.cellViewModels)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: ViewModel Delegate

extension PokedexListView: PokedexListViewViewModelDelegate {
    
    @MainActor
    func didLoadInitialPokemon() async {
        spinner.stopAnimating()
        collectionView.isHidden = false
        updateDataSource()
        UIView.animate(withDuration: 0.4) {
            self.collectionView.alpha = 1
        }
    }
    
    @MainActor
    func didLoadMorePokemon() async {
        updateDataSource()
    }
    
    @MainActor
    func didSelectPokemon(_ pokemon: Pokemon, cell: PokedexCollectionViewCell) async {
        Task { [weak self] in
            guard let self else { return }
            await delegate?.pokePodedexListView(self, didSelectPokemon: pokemon, cell: cell)
        }
    }
}

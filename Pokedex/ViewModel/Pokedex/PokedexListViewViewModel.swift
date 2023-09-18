//
//  PokedexListViewViewModel.swift
//  Pokedex
//
//  Created by Carson Gross on 9/16/23.
//

import UIKit

// MARK: ViewModelDelegate

protocol PokedexListViewViewModelDelegate: AnyObject {
    func didLoadInitialPokemon() async
    func didLoadMorePokemon() async
    func didSelectPokemon(_ pokemon: Pokemon, cell: PokedexCollectionViewCell) async
}

/// View model to handle Pokédex list view logic
final class PokedexListViewViewModel: NSObject, @unchecked Sendable {
    
    public weak var delegate: PokedexListViewViewModelDelegate?
    
    private var pokemon = [Pokemon]() {
        didSet {
            for p in pokemon {
                let viewModel = PokedexCollectionViewCellViewModel(
                    pokemonId: p.id,
                    pokemonName: p.name,
                    pokemonImageURL: URL(string: p.sprites.versions.generationV.blackWhite.animated?.front_default ?? p.sprites.front_default ?? "")
                )
                
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    public private(set) var cellViewModels = [PokedexCollectionViewCellViewModel]()
    
    private var nextURL: String?
    private var isLoadingMorePokemon = false
    
    public var shouldShowLoadMoreIndicator: Bool {
        nextURL != nil
    }
    
    enum PokedexSection {
        case main
        case footer
    }
    
    // MARK: Public
    
    /// Fetch initial set of pokemon
    public func fetchPokemon() {
        let request = PokeRequest(
            endpoint: .pokemon,
            queryParameters: [
                URLQueryItem(
                    name: "limit",
                    value: "20"
                ),
                URLQueryItem(
                    name: "offset",
                    value: "0"
                )
            ]
        )
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let allPokemonResult = try await PokeService.shared.execute(request, expecting: PokeGetAllPokemonResponse.self)
                nextURL = allPokemonResult.next
                pokemon = try await getPokemonFromAllPokemonResponse(allPokemonResult: allPokemonResult)
                await delegate?.didLoadInitialPokemon()
            } catch {
                print(String(describing: error))
            }
        }
    }
    
    // MARK: Private
    
    /// Get more pokemon and add them to the array of Pokémon
    /// - Parameter url: The url for the next page of Pokémon
    private func fetchAdditionalPokemon(url: URL) {
        guard !isLoadingMorePokemon else {
            return
        }
        isLoadingMorePokemon = true
        
        Task { [weak self] in
            guard let self,
                  let request = PokeRequest(url: url) else {
                return
            }
            
            do {
                let result = try await PokeService.shared.execute(request, expecting: PokeGetAllPokemonResponse.self)
                nextURL = result.next
                
                let newPokemon = try await getPokemonFromAllPokemonResponse(allPokemonResult: result, filterAlternates: true)
                pokemon.append(contentsOf: newPokemon)
                
                await delegate?.didLoadMorePokemon()
                isLoadingMorePokemon = false
            } catch {
                isLoadingMorePokemon = false
                print(error.localizedDescription)
            }
        }
    }
    
    /// Coverts the result of getting all pokemon into an array of pokemon
    /// - Parameter allPokemonResult: PokeGetAllPokemonResponse to get the pokemon from
    /// - Parameter filterAlternates: A bool that lets us
    /// - Returns: Array of pokemon
    private func getPokemonFromAllPokemonResponse(allPokemonResult: PokeGetAllPokemonResponse, filterAlternates: Bool = false) async throws -> [Pokemon] {
        return try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            var newPokemon = [Pokemon]()

            for result in allPokemonResult.results {
                guard let url = URL(string: result.url),
                      let pokemonRequest = PokeRequest(url: url) else {
                    continue
                }

                group.addTask {
                    /// Adding a do catch block here so that the throw doesn't propegate up and cancel the whole task
                    /// This way it only affects this iteration of the for loop
                    do {
                        return try await PokeService.shared.execute(pokemonRequest, expecting: Pokemon.self)
                    } catch {
                        print(error)
                        return nil
                    }
                }
            }

            for try await loadedPokemon in group {
                guard let loadedPokemon = loadedPokemon else { continue }
                if loadedPokemon.id > 10_000 && filterAlternates { // Any pokemon over 10,000 is an alternate form so we can choose to not include them
                    nextURL = nil // So we set the nextURL to nil so that we don't get any more
                    continue
                }
                newPokemon.append(loadedPokemon)
            }

            /// Task Groups return based on completions not in order they are stored
            /// So sorting is needed here
            return newPokemon.sorted { $0.id < $1.id }
        }
    }
}

// MARK: CollectionView

extension PokedexListViewViewModel: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let pokemon = pokemon[indexPath.row]
        guard let cell = collectionView.cellForItem(at: indexPath) as? PokedexCollectionViewCell else {
            return
        }
        
        Task { [weak self] in
            guard let self else { return }
            await delegate?.didSelectPokemon(pokemon, cell: cell)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let bounds = collectionView.bounds
        let width = (bounds.width - 30)
        
        return CGSize(
            width: width,
            height: width / 6
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
}

// MARK: ScrollView

extension PokedexListViewViewModel {
    @MainActor func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator,
              !isLoadingMorePokemon,
              !cellViewModels.isEmpty,
              let url = URL(string: nextURL ?? "") else {
            return
        }
        
        let offset = scrollView.contentOffset.y
        let totalContentHeight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
        
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { [weak self] t in
            if offset >= (totalContentHeight - totalScrollViewFixedHeight - 120) {
                self?.fetchAdditionalPokemon(url: url)
            }
            t.invalidate()
        }
    }
}

//
//  ProductListViewModel.swift
//  DigitalShowroom
//
//  Created by Vikas Kharb on 30/01/2022.
//

import Combine
import Foundation

struct ProductListModel {
    var vin: String
    var licensePlate: String
    var imageURL: String
    
    init(response: VinDetails) {
        vin = response.vin
        licensePlate = response.plate
        imageURL = response.imagePath
    }
}

class ProductListViewModel: ObservableObject {
    let manager: NetworkServicesProtocol
    
    var products = [ProductListModel]()
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var finishedLoading: Bool?
    @Published var fetchProductsError: NetworkRequestError?
    
    init(networkManager: NetworkServicesProtocol = NetworkManager.shared) {
        manager = networkManager
    }
    
    func fetchData() {
        fetchProducts()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.finishedLoading = true
                case .failure( let error):
                    self?.fetchProductsError = error
                }
            } receiveValue: { [weak self] payload in
                self?.products = payload.vins.compactMap(ProductListModel.init)
            }
            .store(in: &subscriptions)
    }
    
    private func fetchProducts() -> AnyPublisher<AllProductsResponse, NetworkRequestError> {
        Deferred {
            Future<AllProductsResponse, NetworkRequestError> { [weak self] promise in
                self?.manager.getAllProducts(completion: { result in
                    switch result {
                        
                    case .success(let payload):
                        promise(.success(payload))
            
                    case .failure(let requestError):
                        promise(.failure(requestError))
                    }
                })
                
            }
        }
        .eraseToAnyPublisher()
    }
}

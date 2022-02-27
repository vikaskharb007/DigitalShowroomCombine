//
//  ProductDetailsViewModel.swift
//  DigitalShowroom
//
//  Created by Vikas Kharb on 30/01/2022.
//

import Combine
import Foundation

struct ProductDetailsModel {
    var licencePlateNumber: String
    var isCarLocked: Bool
    var isFrontRightDoorLocked: Bool
    var isFrontLeftDoorLocked: Bool
    var isPassengerRightDoorLocked: Bool
    var isPassengerLeftDoorLocked: Bool
}

class ProductDetailsViewModel: ObservableObject {
    var productDetails: ProductListModel
    private var subscriptions = Set<AnyCancellable>()
    
    @Published var vehichleDetailsFetched: Bool?
    @Published var vehicleCompleteDetails: ProductDetailsModel?
    @Published var lockDetailsFetchError: NetworkRequestError?
    
    let networkManager: NetworkServicesProtocol
    
    init(productData: ProductListModel, manager: NetworkServicesProtocol = NetworkManager.shared) {
        self.productDetails = productData
        self.networkManager = manager
    }
    
    func getVehicleDetails() {
        getLockstatus()
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.vehichleDetailsFetched = true
                case .failure( let error):
                    self?.lockDetailsFetchError = error
                }
            } receiveValue: { [weak self] payload in
                self?.vehicleCompleteDetails = self?.generateVehicleDetails(lockStatus: payload)
            }
            .store(in: &subscriptions)
    }
    
    private func getLockstatus() -> AnyPublisher<DoorsAndWindowsLockStatusResponse, NetworkRequestError> {
        Deferred {
            Future<DoorsAndWindowsLockStatusResponse, NetworkRequestError> { [weak self] promise in
                self?.networkManager.getVehicleLockDetails(vinNumber: self?.productDetails.vin ?? "") { result in
                    switch result {
                    case .success(let response):
                        promise(.success(response))

                    case .failure(let error):
                        self?.lockDetailsFetchError = error
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    private func generateVehicleDetails(lockStatus: DoorsAndWindowsLockStatusResponse) -> ProductDetailsModel {
        return ProductDetailsModel(
            licencePlateNumber: productDetails.licensePlate,
            isCarLocked: lockStatus.locked == "closed",
            isFrontRightDoorLocked: lockStatus.doorRightFront == "closed",
            isFrontLeftDoorLocked: lockStatus.doorLeftFront == "closed",
            isPassengerRightDoorLocked: lockStatus.doorRightBack == "closed",
            isPassengerLeftDoorLocked: lockStatus.doorLeftBack == "closed")
    }
    
}

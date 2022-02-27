//
//  NetworkServicesProtocol.swift
//  DigitalShowroom
//
//  Created by Vikas Kharb on 30/01/2022.
//

import Foundation

protocol NetworkServicesProtocol {
    
    func getVehicleLockDetails(vinNumber: String, completion: @escaping ((Result<DoorsAndWindowsLockStatusResponse, NetworkRequestError>) -> Void))
    
    func getAllProducts(completion: @escaping ((Result<AllProductsResponse, NetworkRequestError>) -> Void))
}

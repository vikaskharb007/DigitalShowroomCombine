//
//  ProductResponse.swift
//  DigitalShowroom
//
//  Created by Vikas Kharb on 30/01/2022.
//

import Foundation

struct AllProductsResponse: Codable {
    var vins: [VinDetails]
}

struct VinDetails: Codable {
    var vin: String
    var plate: String
    var imagePath: String
}

struct DoorsAndWindowsLockStatusResponse: Codable {
    var locked: String
    var doorRightBack: String
    var doorLeftFront: String
    var doorRightFront: String
    var doorLeftBack: String
}

struct Generic: Codable {}

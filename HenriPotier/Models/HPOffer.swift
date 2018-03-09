//
//  HPOffer.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Represents an offer
struct HPOffer: HPOfferRepresentable {
    
    /// Type of the offer.
    var type: HPOfferType = .percentage
    
    /// Value of the offer.
    var value: Int = 0
    
    /// Slice value if the type is `slice`
    var sliceValue: Int? = 0
    
    init() {}
}

//MARK: - Init

extension HPOffer {
    
    init(type: HPOfferType, value: Int, sliceValue: Int?) {
        self.type = type
        self.value = value
        self.sliceValue = sliceValue
    }
}

//MARK: - Discount

extension HPOfferRepresentable {
    
    func priceWithPercentageReductionFor(price: Int) -> Int {
        guard type == .percentage else {
            return price
        }
        return price - (price*value/100)
    }
    
    func priceWithMinusReductionFor(price: Int) -> Int {
        guard type == .minus else {
            return price
        }
        return price - value
    }
    
    func priceWithSliceReductionFor(price: Int) -> Int {
        guard type == .slice, let slice = sliceValue else {
            return price
        }
        return price - (price/slice)*value
    }
}

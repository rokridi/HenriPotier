//
//  HPOffer.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

struct HPOffer: HPOfferRepresentable {
    
    var type: HPOfferType = .percentage
    var value: Int = 0
    var sliceValue: Int?
    
    init() {}
}

extension HPOffer {
    
    init(type: HPOfferType, value: Int, sliceValue: Int?) {
        self.type = type
        self.value = value
        self.sliceValue = sliceValue
    }
}

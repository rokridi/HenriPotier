//
//  HPOfferRepresentable.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Represents a type of an offer.
///
/// - percentage: offer type is percentage.
/// - minus: offer type is minus.
/// - slice: offer type is slice.
enum HPOfferType: String {
    case percentage = "percentage"
    case minus = "minus"
    case slice = "slice"
}

/// Protocol implemented by any entity representing a Book.
protocol HPOfferRepresentable {
    
    /// Type of tyhe offer.
    var type: HPOfferType {get set}
    
    /// Value of the offer.
    var value: Int {get set}
    
    /// Slice value of the offer.
    var sliceValue: Int? {get set}
    
    init()
    init(type: HPOfferType, value: Int, sliceValue: Int?)
}

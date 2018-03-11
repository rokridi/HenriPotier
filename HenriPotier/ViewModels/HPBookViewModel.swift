//
//  HPBookViewModel.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Represents a Book view model.
struct HPBookViewModel: HPBookViewModelable {
    /// ISBN of the book.
    var isbn: String
    
    /// Title of the book.
    var title: String
    
    /// Price of the book.
    var price: Int
    
    /// Synopsis of the book.
    var synopsis: String
    
    init() {
        isbn = ""
        title = ""
        price = 0
        synopsis = ""
    }
    
    init(book: HPBookRepresentable) {
        isbn = book.isbn
        title = book.title
        price = book.price
        synopsis = book.synopsis.joined(separator: "\n")
    }
}

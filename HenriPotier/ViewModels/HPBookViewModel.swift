//
//  HPBookViewModel.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// Represents a Book view model.
struct HPBookViewModel: HPBookViewModelType {
    
    /// ISBN of the book.
    var isbn: String = ""
    
    /// Title of the book.
    var title: String = ""
    
    /// Price of the book.
    var price: Int = 0
    
    /// URL cover.
    var cover: String = ""
    
    /// Synopsis of the book.
    var synopsis: String = ""
    
    init() {
        isbn = ""
        title = ""
        price = 0
        cover = ""
        synopsis = ""
    }
    
    init(book: HPBookType) {
        isbn = book.isbn
        title = book.title
        price = book.price
        cover = book.cover
        synopsis = book.synopsis.joined(separator: "\n")
    }
}

//
//  HPBookRepresentable.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

protocol HPBookRepresentable {
    
    /// ISBN of the book.
    var isbn: String {get set}
    
    /// Title of the book.
    var title: String {get set}
    
    /// Price of the book.
    var price: Int {get set}
    
    /// URL of the cover of the book.
    var cover: String {get set}
    
    /// Synopsis of the book.
    var synopsis: [String] {get set}
    
    init()
    init(isbn: String, title: String, price: Int, cover: String, synopsis: [String])
}

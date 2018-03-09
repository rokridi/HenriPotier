//
//  HPBook.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

struct HPBook: HPBookRepresentable {
    
    var isbn: String = ""
    var title: String = ""
    var price: Int = 0
    var synopsis: [String] = []
    
    init() {}
}

extension HPBook {
    
    init(isbn: String, title: String, price: Int, synopsis: [String]) {
        self.isbn = isbn
        self.title = title
        self.price = price
        self.synopsis = synopsis
    }
}

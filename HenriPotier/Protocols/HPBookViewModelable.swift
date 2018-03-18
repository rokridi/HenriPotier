//
//  HPBookViewModelable.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

protocol HPBookViewModelable {
    var isbn: String {get set}
    var title: String {get set}
    var price: Int {get set}
    var cover: String {get set}
    var synopsis: String {get set}
    
    init()
    init(book: HPBookRepresentable)
}

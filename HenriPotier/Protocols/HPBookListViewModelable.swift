//
//  HPBookListViewModelable.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

protocol HPBookListViewModelable {
    
    associatedtype Client: HTTPClient
    
    var cartQuantity: Int {get set}
    var books: [HPBookRepresentable] {get}
    var loadingClosure: (()->())? {get set}
    var reloadClosure: (()->())? {get set}
    var reloadCartCount: (()->())? {get set}
    func bookSelected(_ indexPath: IndexPath)
    func bookDeselected(_ indexPath: IndexPath)
    
    init<Client>(booksClient: Client)
}
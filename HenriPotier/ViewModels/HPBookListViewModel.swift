//
//  HPBookListViewModel.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift
import HenriPotierApiClient

class HPBookListViewModel: HPBookListViewModelable {
    
    var cartQuantity: Int = 0
    
    private(set) var books: [HPBookRepresentable] = []
    
    var loadingClosure: (() -> ())?
    
    var reloadClosure: (() -> ())?
    
    var reloadCartCount: (() -> ())?
    
    func bookSelected(_ indexPath: IndexPath) {
    }
    
    func bookDeselected(_ indexPath: IndexPath) {
    }
    
    
    typealias Client = HenriPotierApiClient
    
    private var client: Client
    
    required init<Client>(booksClient: Client) {
        client = booksClient as! HPBookListViewModel.Client
    }
    
    func getBooks() {
        
        self.client.fetchBooks(completion: { result in
            
            switch result {
            case .success(let books):
                self.books = books
            case .failure(_):
                self.books = []
            }
        })
    }
}

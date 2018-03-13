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
    
    typealias Client = HenriPotierApiClient
    
    private var client: Client
    
    var cartQuantity: Int {
        return selectedBooks.count
    }
    
    private(set) var books: [HPBookRepresentable] = []
    
    private(set) var selectedBooks: [HPBookRepresentable] = [] {
        didSet {
            //cartQuantity = selectedBooks.count
            reloadCartCount?()
        }
    }
    
    var error: Error? {
        didSet {
            errorClosure?()
        }
    }
    
    var loadingClosure: (() -> ())?
    
    var reloadClosure: (() -> ())?
    
    var reloadCartCount: (() -> ())?
    
    var errorClosure: (() -> ())?
    
    required init<Client>(booksClient: Client) {
        client = booksClient as! HPBookListViewModel.Client
    }
    
    func bookSelected(_ indexPath: IndexPath) {
        selectedBooks.append(books[indexPath.item])
    }
    
    func bookDeselected(_ indexPath: IndexPath) {
        selectedBooks = selectedBooks.filter({ $0.isbn != books[indexPath.item].isbn })
    }
}

extension HPBookListViewModel {
    
    func getBooks() {
        client.fetchBooks(completion: { [weak self] result in
            
            guard let `self` = self else {return}
            
            switch result {
            case .success(let books):
                self.reloadWithBooks(books)
                
            case .failure(let error):
                self.reloadWithBooks([])
                self.error = error
            }
        })
    }
    
    private func reloadWithBooks(_ books: [HPBook]) {
        self.books = books
        selectedBooks = self.selectedBooks.filter({ selectedBook in
            return self.books.contains(where: { $0.isbn == selectedBook.isbn })
        })
        reloadClosure?()
        loadingClosure?()
    }
}

//
//  HPCartViewModel.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 03/04/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HPCartViewModel: HPCartViewModelType {
    
    public struct HPCartViewModelOutput: HPCartViewModelTypeOutput {
        var books: Driver<[HPBookViewModelType]>
        var totalPrice: Driver<String>
        var finalPrice: Driver<String>
        var cartIsEmpty: Driver<Void>
    }
    
    private var books =  Variable<[HPBookViewModelType]>([])
    private let client: HTTPClient
    private let disposeBag = DisposeBag()
    
    required init(books: [HPBookViewModelType], client: HTTPClient) {
        self.client = client
        self.books.value = books
    }
    
    func transform(input: HPCartViewModelTypeInput) -> HPCartViewModelTypeOutput {
        
        let booksObservable = self.books.asObservable()
        
        let totalPrice = booksObservable.map { books in
            String(books.reduce(0, { $0 + $1.price }))+" €"
        }.asDriver(onErrorJustReturn: "0 €")
        
        input.bookDeleted.drive(onNext: { indexPath in
            let deletedBook = self.books.value.remove(at: indexPath.item)
            NotificationCenter.default.post(name: NSNotification.Name.BookDeletedNotification, object: deletedBook.isbn)
        }).disposed(by: disposeBag)
        
        let cartIsEmpty = books.asDriver().map { $0.count <= 0 }.filter({ $0 }).map { _ in () }
        
        let finalPrice = booksObservable.flatMapLatest { booksVM in
            return totalPrice.asObservable().flatMap({ price in
                
                self.client.fetchOffersFor(ISBNs:self.books.value.map({ $0.isbn })).map({ offers in
                    String(offers.map({ $0.bestPriceFor(price: Int("price")!) }).min()!)
                })
            })
        }.asDriver(onErrorDriveWith: totalPrice)
        
        return HPCartViewModelOutput(books: booksObservable.asDriver(onErrorJustReturn: []), totalPrice: totalPrice, finalPrice: finalPrice, cartIsEmpty: cartIsEmpty)
    }
}

extension Notification.Name {
    public static let BookDeletedNotification = Notification.Name("BookDeletedNotification")
}


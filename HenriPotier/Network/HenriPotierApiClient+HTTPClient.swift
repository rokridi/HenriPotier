//
//  HenriPotierApiClient+HTTPClient.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift
import HenriPotierApiClient

extension HenriPotierApiClient: HTTPClient {
    func fetchBooks() -> Observable<[HPBookType]> {
        return books().map({ books in
            books.map({ HPBook(book: $0) })
        })
    }
    
    func fetchOffersFor(ISBNs: [String]) -> Observable<[HPOfferType]> {
        return offers(ISBNs: ISBNs).map({ offers in
            offers.map({ HPOffer(offer: $0) })
        })
    }
}

extension HPBookType {
    init(book: HPApiBook) {
        self.init(isbn: book.isbn, title: book.title, price: book.price, cover: book.cover, synopsis: book.synopsis)
    }
}

extension HPOfferType {
    init(offer: HPApiOffer) {
        self.init()
        type = HPOfferCategory(rawValue: offer.type.rawValue)!
        value = offer.value
        sliceValue = offer.sliceValue
    }
}

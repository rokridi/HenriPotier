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
    
    typealias BookType = HPBook
    typealias OfferType = HPOffer
    
    @discardableResult func fetchBooks() -> Observable<[HPBook]> {
        return books().map {return $0.map({ HPBook(book: $0) })}
    }
    
    @discardableResult func fetchOffersFor(ISBNs: [String]) -> Observable<[HPOffer]> {
        return offers(ISBNs: ISBNs).map {return $0.map({ HPOffer(offer: $0) })}
    }
}

extension HPBookRepresentable {
    init(book: HPApiBook) {
        self.init(isbn: book.isbn, title: book.title, price: book.price, cover: book.cover, synopsis: book.synopsis)
    }
}

extension HPOfferRepresentable {
    init(offer: HPApiOffer) {
        self.init()
        type = HPOfferType(rawValue: offer.type.rawValue)!
        value = offer.value
        sliceValue = offer.sliceValue
    }
}

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
    func fetchBooks<BookType>() -> Observable<[BookType]> where BookType : HPBookType {
        return books().map({ books in
            books.map({ BookType(book: $0) })
        })
    }
    
    func fetchOffersFor<OfferType>(ISBNs: [String]) -> Observable<[OfferType]> where OfferType : HPOfferType {
        return offers(ISBNs: ISBNs).map({ offers in
            offers.map({ OfferType(offer: $0) })
        })
    }
    
    
    @discardableResult func fetchBooks() -> Observable<[HPBook]> {
        return books().map {return $0.map({ HPBook(book: $0) })}
    }
    
    @discardableResult func fetchOffersFor(ISBNs: [String]) -> Observable<[HPOffer]> {
        return offers(ISBNs: ISBNs).map {return $0.map({ HPOffer(offer: $0) })}
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

//
//  HenriPotierApiClient+HTTPClient.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import HenriPotierApiClient

extension HenriPotierApiClient: HTTPClient {
    
    typealias BookType = HPBook
    typealias OfferType = HPOffer
    
    @discardableResult func fetchBooks(completion: @escaping ((Result<[HPBook]>) -> Void)) -> URLSessionTask? {
        return books { result in
            switch result {
            case .success(let books):
                completion(.success(books.map({ HPBook(book: $0) })))
                print("")
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    @discardableResult func fetchOffersFor(ISBNs: [String], completion: @escaping ((Result<[HPOffer]>) -> Void)) -> URLSessionTask? {
        return offers(ISBNs: ISBNs) { result in
            switch result {
            case .success(let offers):
                completion(.success(offers.map({ HPOffer(offer: $0) })))
                print("")
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension HPBookRepresentable {
    init(book: Book) {
        self.init()
        isbn = book.isbn
        title = book.title
        price = book.price
        synopsis = book.synopsis
    }
}

extension HPOfferRepresentable {
    init(offer: Offer) {
        self.init()
        type = HPOfferType(rawValue: offer.type.rawValue)!
        value = offer.value
        sliceValue = offer.sliceValue
    }
}

//
//  HTTPClient.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift

/// This protocol should be implemented by any HTTP client that provides books and offers.
protocol HTTPClient {
    
    associatedtype BookType: HPBookRepresentable
    associatedtype OfferType: HPOfferRepresentable
    
    /// Fetch books from Henri Potier API.
    ///
    /// - Returns: Observable<BookType>.
    @discardableResult func fetchBooks() -> Observable<[BookType]>
    
    /// Fetch offers for a list of books (represented by their ISBNs).
    ///
    /// - Parameters:
    ///   - ISBNs: ISBNs of the books.
    /// - Returns: Observable<HPOfferRepresentable>.
    @discardableResult func fetchOffersFor(ISBNs: [String]) -> Observable<[OfferType]>
}

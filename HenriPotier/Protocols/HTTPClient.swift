//
//  HTTPClient.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation

/// This protocol should be implemented by any HTTP client that provides books and offers.
protocol HTTPClient {
    
    associatedtype BookType: HPBookRepresentable
    associatedtype OfferType: HPOfferRepresentable
    
    /// Fetch books from Henri Potier API.
    ///
    /// - Parameter completion: closure to be called when task finishes.
    /// - Returns: URLSessionTask.
    @discardableResult func fetchBooks(completion: @escaping ((Result<[BookType]>) -> Void)) -> URLSessionTask?
    
    /// Fetch offers for a list of books (represented by their ISBNs).
    ///
    /// - Parameters:
    ///   - ISBNs: ISBNs of the books.
    ///   - completion: closure to be called when task finishes.
    /// - Returns: URLSessionTask.
    @discardableResult func fetchOffersFor(ISBNs: [String], completion: @escaping ((Result<[OfferType]>) -> Void)) -> URLSessionTask?
}

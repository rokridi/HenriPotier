//
//  HPBooksViewModelType.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 30/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import HenriPotierApiClient
import RxSwift
import RxCocoa

protocol HPBooksViewModelInputType {
    var refreshBooks: Driver<Void> {get set}
    var bookSelected: Driver<IndexPath> {get set}
    var bookAdded: Driver<String> {get set}
    var cartRequested: Driver<Void> {get set}
}

protocol HPBooksViewModelOutputType {
    var books: Driver<[HPBookViewModelType]> {get set}
    var selectedBook: Driver<HPBookViewModelType> {get set}
    var cartBooksCount: Driver<Int> {get set}
    var cartButtonEnabled: Driver<Bool> {get set}
    var error: Driver<String> {get set}
    var isRefreshing: Driver<Bool> {get set}
    var isRetrying: Driver<Bool> {get set}
    var isReachable: Driver<Bool> {get set}
    var cart: Driver<HPCartViewModel> {get set}
}

protocol HPBooksViewModelType {
    
    init(client: HTTPClient)
    func transform(input: HPBooksViewModelInputType) -> HPBooksViewModelOutputType
}

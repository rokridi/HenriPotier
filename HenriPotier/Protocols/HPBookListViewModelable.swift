//
//  HPBookListViewModelable.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift

protocol HPBookListViewModelable {
    
    var books: Variable<[HPBookViewModelable]> {get set}
    var selectedBooks: Variable<[HPBookViewModelable]> {get set}
    var selectedBooksCount: Variable<Int> {get set}
    var refreshBooks: PublishSubject<Void> {get set}
    var bookSelected: PublishSubject<HPBookViewModelable> { get set }
    var bookDeseleted: PublishSubject<Int> { get set }

    init<HTTPClient>(client: HTTPClient)
    func getBooks() -> Observable<Void>
    func totalPrice() -> Observable<Int>
    func finalPrice() -> Observable<Int>
}

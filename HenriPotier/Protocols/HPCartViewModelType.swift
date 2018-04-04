//
//  HPCartViewModelType.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 03/04/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol HPCartViewModelTypeInput {
    var bookDeleted: PublishSubject<Void> {get set}
    var cartValidated: PublishSubject<Void> {get set}
}

protocol HPCartViewModelTypeOutput {
    var books: Driver<[HPBookViewModelType]> {get set}
    var totalPrice: Driver<Int> {get set}
    var finalPrice: Driver<Int> {get set}
    var cartIsEmpty: Driver<Bool> {get set}
}
    
protocol HPCartViewModelType {
    init(books: [HPBookViewModelType])
}

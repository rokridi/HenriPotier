//
//  HPCartViewModelable.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift

protocol HPCartViewModelInput {
    var bookRemoved: PublishSubject<Bool> {get set}
}

protocol HPCartViewModelOutput {
    var cartQuantity: Variable<Int> {get set}
    var books: Variable<[HPBookRepresentable]> {get set}
}

protocol HPCartViewModelable {
    var input: HPCartViewModelInput {get set}
    var output: HPCartViewModelOutput {get set}
}

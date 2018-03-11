//
//  HPBookListViewModelInput.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift

protocol HPBookListViewModelInput {
    var refreshBooks: PublishSubject<Bool> { get set }
    var bookSelected: PublishSubject<Bool> {get set}
    var bookUnselected: PublishSubject<Bool> {get set}
}

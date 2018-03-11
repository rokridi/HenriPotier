//
//  HPBookListViewModelOutput.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift

protocol HPBookListViewModelOutput {
    var cartQuantity: Variable<Int> {get set}
    var books: Variable<[HPBookRepresentable]> {get set}
    
}

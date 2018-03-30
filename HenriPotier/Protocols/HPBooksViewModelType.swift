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
}

protocol HPBooksViewModelOutputType {
    var refreshing: Driver<Bool> {get set}
}

protocol HPBooksViewModelType {
    
    init<Client: HTTPClient>(client: Client)
    func transform(input: HPBooksViewModelInputType) -> HPBooksViewModelOutputType
}

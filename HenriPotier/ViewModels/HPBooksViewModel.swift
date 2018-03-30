//
//  HPBooksViewModel.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import HenriPotierApiClient

class HPBooksViewModel: HPBooksViewModelType {
    
    public struct HPBooksViewModelInput: HPBooksViewModelInputType {
        var refreshBooks: Driver<Void>
    }
    
    public struct HPBooksViewModelOutput: HPBooksViewModelOutputType {
        var refreshing: Driver<Bool>
        var books: Driver<HPBookType>
        var selectedBooksCount: Driver<Int>
    }
    
    let client: HTTPClient
    
    required init<Client>(client: Client) where Client : HTTPClient {
        self.client = client
    }
    
    func transform(input: HPBooksViewModelInputType) -> HPBooksViewModelOutputType {
        return HPBooksViewModelOutput(refreshing: nil, books: nil, selectedBooksCount: nil)
    }
    
  
}

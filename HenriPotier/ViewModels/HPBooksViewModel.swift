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
import RxAlertController
import HenriPotierApiClient

class HPBooksViewModel: HPBooksViewModelType {
    
    public struct HPBooksViewModelInput: HPBooksViewModelInputType {
        var refreshBooks: Driver<Void>
        var bookSelected: Driver<IndexPath>
    }
    
    public struct HPBooksViewModelOutput: HPBooksViewModelOutputType {
        var books: Driver<[HPBookViewModelType]>
        var selectedBook: Driver<HPBookViewModelType>
        var cartBooksCount: Observable<Int>
        var cartButtonEnabled: Observable<Bool>
        var error: Driver<String>
        var isRefreshing: Driver<Bool>
    }
    
    private let client: HTTPClient
    private var cartBooks = Variable<[HPBookViewModelType]>([])
    private var error = PublishSubject<String>()
    private var isRefreshing = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
        
    required init(client: HTTPClient) {
        self.client = client
    }
    
    func transform(input: HPBooksViewModelInputType) -> HPBooksViewModelOutputType {
        
        let outputError = self.error.asDriver(onErrorJustReturn: "kkkkkk")
        
        let outputBooks = input.refreshBooks.flatMapLatest { [unowned self] _  -> Driver<[HPBookViewModelType]> in
            
            self.isRefreshing.onNext(true)
            return self.client.fetchBooks().map({ [weak self] books  in
                self?.isRefreshing.onNext(false)
                return books.map({ return HPBookViewModel(book: $0) })}).do(onNext: { [weak self] _ in
                    self?.isRefreshing.onNext(false)
                })
                .retryWhen({ errorObservable -> Observable<Error> in
                    return errorObservable.enumerated().flatMap({ [weak self] (index, error) -> Observable<Error> in
                        
                        guard index < 3, case let ApiError.unknownError(error: anError) = error, (anError as NSError).code == -1003  else {
                            //Do not retry.
                            self?.isRefreshing.onNext(false)
                            return errorObservable.flatMap { Observable.error($0) }
                        }
                        
                        self?.isRefreshing.onNext(true)
                        //Retry
                        return Observable.just(error)
                    })
                })
                .asDriver(onErrorJustReturn: [])
        }
        
        let selectedBook = input.bookSelected.withLatestFrom(outputBooks) { (indexPath, aBooks) in
            return aBooks[indexPath.item]
        }.asDriver()
        
        let cartBooksCount = cartBooks.asObservable().map { $0.count }
        let cartButtonEnabled = cartBooks.asObservable().map { $0.count > 0 }
        
        return HPBooksViewModelOutput(books: outputBooks, selectedBook: selectedBook, cartBooksCount: cartBooksCount, cartButtonEnabled: cartButtonEnabled, error: outputError, isRefreshing: self.isRefreshing.asDriver(onErrorJustReturn: false))
    }
}

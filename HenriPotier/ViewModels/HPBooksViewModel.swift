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
import Reachability
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
        var isRetrying: Driver<Bool>
        var isConnected: Driver<Void>
        var isDisconnected: Driver<Void>
    }
    
    private var cartBooks = Variable<[HPBookViewModelType]>([])
    private var error = PublishSubject<String>()
    private var isRefreshing = PublishSubject<Bool>()
    private var isRetrying = PublishSubject<Bool>()
    private let client: HTTPClient
    let reachability = Reachability(hostname: "http://henri-potier.xebia.fr")!
    private let disposeBag = DisposeBag()
        
    required init(client: HTTPClient) {
        self.client = client
        try? reachability.startNotifier()
    }
    
    func transform(input: HPBooksViewModelInputType) -> HPBooksViewModelOutputType {
        
        let outputError = self.error.asDriver(onErrorJustReturn: "")
        
        let booksObservable = self.client.fetchBooks().do(onNext: { books in
            self.isRefreshing.onNext(false)
        }, onError: { error in
            self.isRefreshing.onNext(false)
            self.error.onNext(error.localizedDescription)
        }, onSubscribed: {
            self.isRefreshing.onNext(true)
        }).retryWhen({ (errorObservable: Observable<Error>) in
            return errorObservable.enumerated().flatMap({ (attempt, error) -> Observable<Void> in
                
                guard attempt < 4 else {
                    return Observable.error(error)
                }
                let didBecomeReachable: Observable<Void> = self.reachability.rx.isConnected
                
                return Observable.merge(didBecomeReachable)
            })
        })
        
        let outputBooks = input.refreshBooks.flatMapLatest { _  -> Driver<[HPBookViewModelType]> in
            return booksObservable.map({ books  in return books.map({ return HPBookViewModel(book: $0) })}).asDriver(onErrorJustReturn: [])
        }
        
        let selectedBook = input.bookSelected
            .withLatestFrom(outputBooks.asDriver(onErrorJustReturn: [])) { $1[$0.item]}
            .asDriver()
        
        let cartBooksCount = cartBooks.asObservable().map { $0.count }
        let cartButtonEnabled = cartBooks.asObservable().map { $0.count > 0 }
        let isRefreshing = self.isRefreshing.asDriver(onErrorJustReturn: false)
        let isRetrying = self.isRetrying.asDriver(onErrorJustReturn: false)
        let isConnected = reachability.rx.isConnected.asDriver(onErrorJustReturn: ())
        let isDisconnected = reachability.rx.isDisconnected.asDriver(onErrorJustReturn: ())
        
        return HPBooksViewModelOutput(books: outputBooks,
                                      selectedBook: selectedBook,
                                      cartBooksCount: cartBooksCount,
                                      cartButtonEnabled: cartButtonEnabled,
                                      error: outputError,
                                      isRefreshing: isRefreshing,
                                      isRetrying: isRetrying,
                                      isConnected: isConnected,
                                      isDisconnected: isDisconnected)
    }
}

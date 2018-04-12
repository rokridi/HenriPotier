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
    
    public struct HPBooksViewModelOutput: HPBooksViewModelOutputType {
        var books: Driver<[HPBookViewModelType]>
        var selectedBook: Driver<HPBookViewModelType>
        var cartBooksCount: Driver<Int>
        var cartButtonEnabled: Driver<Bool>
        var error: Driver<String>
        var isRefreshing: Driver<Bool>
        var isRetrying: Driver<Bool>
        var isReachable: Driver<Bool>
        var cart: Driver<HPCartViewModel>
    }
    
    private let reachability = Reachability()!
    private var shouldNotifiyReachabilityStatus = BehaviorRelay<Bool>(value: false)
    
    private var cartBooks = Variable<[HPBookViewModelType]>([])
    private var error = PublishSubject<String>()
    private var isRefreshing = PublishSubject<Bool>()
    private var isRetrying = PublishSubject<Bool>()
    private var isReachable = BehaviorRelay<Bool>(value: false)
    private let client: HTTPClient
    private let disposeBag = DisposeBag()
    private var disposable: Disposable!
        
    required init(client: HTTPClient) {
        self.client = client
        try? reachability.startNotifier()
    }
    
    func transform(input: HPBooksViewModelInputType) -> HPBooksViewModelOutputType {
        
        let outputError = self.error.asDriver(onErrorJustReturn: "")
        
        let booksObservable = self.client.fetchBooks()
            .do(onNext: { books in
                self.isRefreshing.onNext(false)
            }, onError: { error in
                self.isRefreshing.onNext(false)
                self.error.onNext(error.localizedDescription)
            }, onSubscribed: {
                self.isRefreshing.onNext(true)
            })
            .retryWhen({ _ in
                return self.reachability.rx.isConnected
            })
        
        let outputBooks = input.refreshBooks.flatMapLatest { _ -> Driver<[HPBookViewModelType]> in
            return booksObservable.map({ books in return books.map({ return HPBookViewModel(book: $0) })}).asDriver(onErrorJustReturn: [])
        }
        
        input.bookAdded.withLatestFrom(outputBooks) { (bookID, books) -> Void in
            let book = books.first(where: { $0.isbn == bookID })
            guard let bookVM = book else { return }
            self.cartBooks.value.append(bookVM)
        }.drive().disposed(by: disposeBag)
        
        let selectedBook = input.bookSelected
            .withLatestFrom(outputBooks.asDriver(onErrorJustReturn: [])) { $1[$0.item]}
            .asDriver()
        
        let cart = input.cartRequested.map { _ -> HPCartViewModel in
            
            if self.disposable != nil {
                self.disposable.dispose()
            }
            
            let cartVM = HPCartViewModel(books: self.cartBooks.value, client: self.client)
            
            NotificationCenter.default.removeObserver(self, name: Notification.Name.BookDeletedNotification, object: nil)
            
            self.disposable = NotificationCenter.default.rx.notification(Notification.Name.BookDeletedNotification).subscribe(onNext: { notification in
                let isbn = notification.object as? String
                
                if let isbn = isbn, let index = self.cartBooks.value.index(where: { $0.isbn == isbn }) {
                    self.cartBooks.value.remove(at: index)
                }
            })
            
            return cartVM
        }
        
        let cartBooksCount = cartBooks.asDriver().map { $0.count }
        let cartButtonEnabled = cartBooks.asDriver().map { $0.count > 0 }
        let isRefreshing = self.isRefreshing.asDriver(onErrorJustReturn: false)
        let isRetrying = self.isRetrying.asDriver(onErrorJustReturn: false)

        reachability.rx.isReachable.asDriver(onErrorJustReturn: false).drive(onNext: { [weak self] reachable in
            
            guard let `self` = self else { return }
            
            if reachable, !self.shouldNotifiyReachabilityStatus.value {
                self.shouldNotifiyReachabilityStatus.accept(true)
                return
            }
            
            self.shouldNotifiyReachabilityStatus.accept(true)
            self.isReachable.accept(reachable)
            
        }).disposed(by: disposeBag)
        
        return HPBooksViewModelOutput(books: outputBooks,
                                      selectedBook: selectedBook,
                                      cartBooksCount: cartBooksCount,
                                      cartButtonEnabled: cartButtonEnabled,
                                      error: outputError,
                                      isRefreshing: isRefreshing,
                                      isRetrying: isRetrying,
                                      isReachable: self.isReachable.asDriver(onErrorJustReturn: false).skip(1),
                                      cart: cart)
    }
}

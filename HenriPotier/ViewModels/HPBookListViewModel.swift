//
//  HPBookListViewModel.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 11/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import Foundation
import RxSwift
import HenriPotierApiClient

class HPBookListViewModel: HPBookListViewModelable {
    
    typealias Client = HenriPotierApiClient
    typealias Book = HPBookViewModel
    
    var books: Variable<[HPBookViewModelable]> = Variable([HPBookViewModel]())
    var selectedBooks: Variable<[HPBookViewModelable]> = Variable([HPBookViewModel]())
    var selectedBooksCount: Variable<Int> = Variable(0)
    var bookSelected: PublishSubject<HPBookViewModelable> = PublishSubject()
    var bookDeseleted: PublishSubject<Int> = PublishSubject()
    
    var refreshBooks: PublishSubject<Void> = PublishSubject()
    
    private var client: Client
    private var disposeBag = DisposeBag()
    
    required init<Client>(client: Client) {
        self.client = client as! HPBookListViewModel.Client
    }
    
    required init(client: HenriPotierApiClient) {
        
        self.client = client
        
        bookSelected.asObservable().subscribe(onNext: { selectedBook in
            
            guard let _ = self.books.value.first(where: { selectedBook.isbn == $0.isbn }) else {
                return
            }
            self.selectedBooks.value.append(selectedBook)
            self.selectedBooksCount.value = self.selectedBooks.value.count
            
        }).disposed(by: disposeBag)
        
        bookDeseleted.asObservable().subscribe(onNext: { deletedBookIndex in
            
            if 0...self.selectedBooks.value.count-1 ~= deletedBookIndex {
                self.selectedBooks.value.remove(at: deletedBookIndex)
                self.selectedBooksCount.value = self.selectedBooks.value.count
            }
        }).disposed(by: disposeBag)
    }
    
    func getBooks() -> Observable<Void> {
        
        return self.refreshBooks.flatMapLatest({ isRefreshing -> Observable<Void> in
            return self.client.fetchBooks().map { books in
                self.books.value = books.map({ HPBookViewModel(book: $0) })
                }
                .do(onError: { error in
                    self.books.value = []
                })
        })
    }
    
    func totalPrice() -> Observable<Int> {
        return selectedBooks.asObservable()
            .flatMapLatest({ _ -> Observable<Int> in
                let total = self.selectedBooks.value.reduce(0) { $0 + $1.price }
                return Observable.just(total)
            })
    }
    
    func finalPrice() -> Observable<Int> {
        
        return totalPrice().flatMapLatest { total -> Observable<(Int, HPOfferRepresentable)> in
            self.bestOffer(total: total).flatMapLatest({ bestOffer -> Observable<(Int, HPOfferRepresentable)> in
                return Observable.just((total, bestOffer))
            })
        }.flatMapLatest { (total, bestOffer) -> Observable<Int> in
            return Observable.just(bestOffer.bestPriceFor(price: total))
        }
    }
    
    func bestOffer(total: Int) -> Observable<HPOfferRepresentable> {
        return offers().flatMapLatest({ offers -> Observable<HPOfferRepresentable> in
            
            let bestOffer = offers.reduce(offers.first!) { $0.bestPriceFor(price: total) > $1.bestPriceFor(price: total) ? $0 : $1
            }
            return Observable.just(bestOffer)
        })
    }
    
    func offers() -> Observable<[HPOffer]> {
        if selectedBooks.value.count > 0 {
            let isbns = selectedBooks.value.map({ $0.isbn })
            return client.fetchOffersFor(ISBNs: isbns)
        } else {
            return Observable.just([])
        }
    }
}

//
//  BooksViewController.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 09/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HenriPotierApiClient
import MIBadgeButton_Swift

class BooksViewController: UIViewController {
    
    var viewModel: HPBookListViewModelable!
    let cartButton = MIBadgeButton(type: .custom)
    private let disposeBag = DisposeBag()
    private var refreshControl = UIRefreshControl()
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let client = HenriPotierApiClient(baseURL: "http://henri-potier.xebia.fr")
        viewModel = HPBookListViewModel(client: client)
        
        setupCollectionView()
        setupRefreshControl()
        setupCartButton()
        
        viewModel.getBooks()
            .subscribe(onNext: { success in
                self.refreshControl.endRefreshing()
            }, onError: { error in
                self.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        refreshBooks()
    }
}

extension BooksViewController: BookDetailViewControllerDelegate {
    func bookDetailViewController(_ viewController: BookDetailViewController, didAddBookToCart book: HPBookViewModelable) {
        viewModel.bookSelected.onNext(book)
    }
    
    func bookDetailViewControllerDidDismiss(_ viewController: BookDetailViewController) {
    }
}

extension BooksViewController {
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(BooksViewController.refreshBooks), for: .valueChanged)
        collectionView.refreshControl = self.refreshControl
    }
    
    private func setupCollectionView() {
        
        collectionView.register(UINib(nibName: "\(BookCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(BookCollectionViewCell.self)")
        
        viewModel.books.asObservable().bind(to: collectionView.rx.items(cellIdentifier: "\(BookCollectionViewCell.self)", cellType: BookCollectionViewCell.self)) { index, model, cell in
            cell.book = model
            }.disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(HPBookViewModelable.self)
            .subscribe(onNext: { bookViewModel in
                
                let bookDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "\(BookDetailViewController.self)") as! BookDetailViewController
                bookDetailVC.bookViewModel = bookViewModel
                bookDetailVC.delegate = self
                self.navigationController?.present(bookDetailVC, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
    
    private func setupCartButton() {
        cartButton.setImage(#imageLiteral(resourceName: "cart"), for: .normal)
        cartButton.addTarget(self, action: #selector(BooksViewController.showCart), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        viewModel.selectedBooksCount.asObservable().bind { selectedBooksCount in
            self.cartButton.badgeString = selectedBooksCount > 0 ? "\(selectedBooksCount)" : ""
            self.navigationItem.rightBarButtonItem?.isEnabled = selectedBooksCount > 0
        }.disposed(by: disposeBag)
    }
    
    @objc private func showCart() {
        let cartVC = storyboard?.instantiateViewController(withIdentifier: "\(CartViewController.self)") as! CartViewController
        cartVC.viewModel = viewModel
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc private func refreshBooks() {
        viewModel.refreshBooks.onNext(())
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension BooksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width * 0.5 - 16, height: (self.view.frame.size.width * 0.5) * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
    }
}

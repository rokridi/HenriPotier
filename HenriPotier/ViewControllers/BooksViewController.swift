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
    
    var viewModel: HPBooksViewModelType!
    var error = ""
    
    let cartButton = MIBadgeButton(type: .custom)
    private let disposeBag = DisposeBag()
    private var refreshControl = UIRefreshControl()
    @IBOutlet private weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupRefreshControl()
        setupCollectionView()
        setupCartButton()
        setupViewModel()
    }
}

extension BooksViewController {
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(BooksViewController.refreshBooks), for: .valueChanged)
        collectionView.refreshControl = self.refreshControl
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "\(BookCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(BookCollectionViewCell.self)")
    }
    
    private func setupCartButton() {
        cartButton.setImage(#imageLiteral(resourceName: "cart"), for: .normal)
        cartButton.addTarget(self, action: #selector(BooksViewController.showCart), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setupViewModel() {
        viewModel = HPBooksViewModel(client: HenriPotierApiClient(baseURL: "http://henri-pot"))//http://henri-potier.xebia.fr
        
        let viewDidLoadTrigger = self.rx
            .sentMessage(#selector(UIViewController.viewDidLoad))
            .map({ _ in Void() })
            .asDriver(onErrorJustReturn: Void())
        
        let pullTrigger = collectionView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .map({ _ in Void() })
            .asDriver(onErrorJustReturn: Void())
        
        let refreshTrigger = Driver.merge(viewDidLoadTrigger, pullTrigger).do(onNext: {
            self.refreshControl.endRefreshing()
        })
        
        //let refreshTrigger = Driver.combineLatest(viewDidLoadTrigger, pullTrigger)
        let input = HPBooksViewModel.HPBooksViewModelInput(refreshBooks: refreshTrigger, bookSelected: collectionView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        
        output.books.asObservable().bind(to: collectionView.rx.items) { (collectionView, row, element ) in
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "\(BookCollectionViewCell.self)", for: IndexPath(row : row, section : 0)) as! BookCollectionViewCell
            cell.bookViewModel = element
            return cell
            }.disposed(by: disposeBag)
        
        output.isRefreshing
            .drive(self.collectionView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output.error.drive(onNext: { error in
            print("Error: \(error)")
        }).disposed(by: disposeBag)
        
        output.selectedBook.drive(onNext: { bookVM in
            print("selectedBook: \(bookVM)")
        }).disposed(by: disposeBag)
    }
    
    @objc private func showCart() {
        let cartVC = storyboard?.instantiateViewController(withIdentifier: "\(CartViewController.self)") as! CartViewController
        cartVC.viewModel = viewModel
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    @objc private func refreshBooks() {
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension BooksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.size.width * 0.5 - 16, height: (self.view.frame.size.width * 0.5) * 1.4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
    }
}

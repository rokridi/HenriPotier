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
import SwiftMessages

class BooksViewController: UIViewController {
    
    struct HPBooksViewModelInput: HPBooksViewModelInputType {
        var refreshBooks: Driver<Void>
        var bookSelected: Driver<IndexPath>
        var bookAdded: Driver<String>
        var cartRequested: Driver<Void>
    }
    
    var viewModel: HPBooksViewModelType!
    
    private var errorMessages: SwiftMessages = {
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .automatic
        
        let messages = SwiftMessages()
        messages.defaultConfig = config
        
        return messages
    }()
    
    private var addedBookID = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    private let cartButton = MIBadgeButton(type: .custom)
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

//MARK: - ViewModel

extension BooksViewController {
    
    private func setupViewModel() {
        
        viewModel = HPBooksViewModel(client: HenriPotierApiClient(baseURL: "http://henri-potier.xebia.fr"))//http://henri-potier.xebia.fr
        
        let viewWillAppearTrigger = self.rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map({ _ in Void() })
            .asDriver(onErrorJustReturn: Void())
        
        let pullTrigger = collectionView.refreshControl!.rx
            .controlEvent(.valueChanged)
            .map({ _ in Void() })
            .asDriver(onErrorJustReturn: Void())
        
        let refreshTrigger = Driver.merge(viewWillAppearTrigger, pullTrigger)
        
        let input = HPBooksViewModelInput(refreshBooks: refreshTrigger, bookSelected: collectionView.rx.itemSelected.asDriver(), bookAdded: addedBookID.asDriver(), cartRequested: cartButton.rx.tap.asDriver())
        let output = viewModel.transform(input: input)
        
        output.books.asObservable().bind(to: collectionView.rx.items) { (collectionView, row, bookVM ) in
            let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "\(BookCollectionViewCell.self)", for: IndexPath(row : row, section : 0)) as! BookCollectionViewCell
            cell.bookVM = bookVM
            return cell
            }.disposed(by: disposeBag)
        
        output.isRefreshing
            .drive(self.collectionView.refreshControl!.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        output.error.drive(onNext: { error in
            self.showError(error)
        }).disposed(by: disposeBag)
        
        output.selectedBook.drive(onNext: { bookVM in
            let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "\(BookDetailViewController.self)") as! BookDetailViewController
            detailVC.bookVM = bookVM
            detailVC.delegate = self
            self.present(detailVC, animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        output.isReachable.drive(onNext: { [weak self] isReachable in
            if isReachable {
                self?.showInternetIsBackAlert()
            } else {
                self?.showInternetIsDownAlert()
            }
        }).disposed(by: disposeBag)
        
        output.cart.drive(onNext: { cartVM in
            let cartVC = self.storyboard?.instantiateViewController(withIdentifier: "\(CartViewController.self)") as! CartViewController
            cartVC.viewModel = cartVM
            self.navigationController?.pushViewController(cartVC, animated: true)
        }).disposed(by: disposeBag)
        
        output.cartButtonEnabled.drive(cartButton.rx.isEnabled).disposed(by: disposeBag)
        output.cartBooksCount.drive(onNext: { count in
            self.cartButton.badgeString = count>0 ? String(count) : nil
        }).disposed(by: disposeBag)
    }
}

extension BooksViewController {
    
    private func setupRefreshControl() {
        collectionView.refreshControl = self.refreshControl
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "\(BookCollectionViewCell.self)", bundle: nil), forCellWithReuseIdentifier: "\(BookCollectionViewCell.self)")
    }
    
    private func bookAddedToCart(_ book: HPBookViewModelType) {
        
    }
    
    private func setupCartButton() {
        cartButton.setImage(#imageLiteral(resourceName: "cart"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: cartButton)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func showError(_ message: String) {
        
        let messageView = MessageView.viewFromNib(layout: .messageView)
        messageView.configureTheme(.error)
        messageView.configureContent(title: "", body: message)
        messageView.button?.isHidden = true
        errorMessages.show(view: messageView)
    }
    
    private func showWarning(_ message: String) {
        let errorMessageView = MessageView.viewFromNib(layout: .statusLine)
        errorMessageView.configureTheme(.warning)
        errorMessageView.configureContent(title: "", body: message)
        errorMessageView.button?.isHidden = true
        errorMessageView.iconImageView?.image = nil
        SwiftMessages.show(view: errorMessageView)
    }
    
    private func showInternetIsDownAlert() {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .forever
        config.interactiveHide = false
        config.ignoreDuplicates = true
        
        let messageView = MessageView.viewFromNib(layout: .statusLine)
        messageView.configureTheme(.info)
        messageView.configureContent(title: "", body: "Internet is down !")
        messageView.id = "down"
        SwiftMessages.show(config: config, view: messageView)
    }
    
    private func showInternetIsBackAlert() {
        
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .automatic
        config.interactiveHide = false
        
        let messageView = MessageView.viewFromNib(layout: .statusLine)
        messageView.configureTheme(.info)
        messageView.configureContent(title: "", body: "Internet is back !")
        messageView.id = "back"
        SwiftMessages.hide(id: "down")
        SwiftMessages.show(config: config, view: messageView)
    }
    
    private func warningMessageConfig() -> SwiftMessages.Config {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .automatic
        return config
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

//MARK: - BookDetailViewControllerDelegate

extension BooksViewController: BookDetailViewControllerDelegate {
    
    func bookDetailViewController(_ viewController: BookDetailViewController, didAddBookToCart book: HPBookViewModelType) {
        addedBookID.accept(book.isbn)
    }
    
    func bookDetailViewControllerDidDismiss(_ viewController: BookDetailViewController) {
    }
}

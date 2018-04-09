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
            self.showError(error)
        }).disposed(by: disposeBag)
        
        output.selectedBook.drive(onNext: { bookVM in
            print("selectedBook: \(bookVM)")
        }).disposed(by: disposeBag)
        
        output.isConnected.dri
        
        output.isDisconnected.drive(onNext: { isReachable in
            isReachable ? self.showInternetIsBackAlert() : self.showInternetIsDownAlert()
        }).disposed(by: disposeBag)
    }
    
    @objc private func showCart() {
        let cartVC = storyboard?.instantiateViewController(withIdentifier: "\(CartViewController.self)") as! CartViewController
        cartVC.viewModel = viewModel
        navigationController?.pushViewController(cartVC, animated: true)
    }
    
    private func showError(_ message: String) {
        var config = SwiftMessages.Config()
        config.presentationStyle = .top
        config.duration = .automatic
        config.ignoreDuplicates = false
        
        let messageView = MessageView.viewFromNib(layout: .messageView)
        messageView.configureTheme(.error)
        messageView.configureContent(title: "", body: message)
        messageView.button?.isHidden = true
        SwiftMessages.show(config: config, view: messageView)
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
        config.duration = .automatic
        config.ignoreDuplicates = false
        let messageView = MessageView.viewFromNib(layout: .statusLine)
        messageView.configureTheme(.info)
        messageView.configureContent(title: "", body: "Internet is down !")
        SwiftMessages.show(config: config, view: messageView)
    }
    
    private func showInternetIsBackAlert() {
        var config = SwiftMessages.Config()
        config.presentationStyle = .bottom
        config.duration = .automatic
        config.ignoreDuplicates = false
        
        let messageView = MessageView.viewFromNib(layout: .statusLine)
        messageView.configureTheme(.info)
        messageView.configureContent(title: "", body: "Internet is back !")
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

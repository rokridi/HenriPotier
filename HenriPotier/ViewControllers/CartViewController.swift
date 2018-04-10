//
//  CartViewController.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 18/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import HenriPotierApiClient

class CartViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    struct HPCartViewModelInput: HPCartViewModelTypeInput  {
        var bookDeleted: Driver<IndexPath>
        //var cartValidated: PublishSubject<Void> {get set}
    }
    
    let disposeBag = DisposeBag()
    
    var viewModel: HPCartViewModelType!
    
    @IBAction func validateAndPay(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cart"
        setupTableView()
        setupViewModel()
    }
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: "\(BookTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(BookTableViewCell.self)")
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        tableView.rx
            .itemSelected
            .asObservable()
            .subscribe(onNext:{ indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupViewModel() {
        let deleteTrigger = tableView.rx.itemDeleted.asDriver(onErrorJustReturn: IndexPath(item: 0, section: 0))
        
        let input = HPCartViewModelInput(bookDeleted: deleteTrigger)
        let output = viewModel.transform(input: input)
        
        output.books.asObservable().bind(to: tableView.rx.items) { (collectionView, row, bookVM ) in
            let cell  = collectionView.dequeueReusableCell(withIdentifier: "\(BookTableViewCell.self)", for: IndexPath(row : row, section : 0)) as! BookTableViewCell
            cell.bookVM = bookVM
            return cell}
            .disposed(by: disposeBag)
        
        output.cartIsEmpty
            .drive(onNext: { self.navigationController?.popViewController(animated: true) })
            .disposed(by: disposeBag)
        
        output.totalPrice.drive(self.priceLabel.rx.text).disposed(by: disposeBag)
        
        output.finalPrice.drive(self.finalPriceLabel.rx.text).disposed(by: disposeBag)
    }
}

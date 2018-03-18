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

class CartViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var finalPriceLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    var viewModel: HPBookListViewModelable!
    
    @IBAction func validateAndPay(_ sender: UIButton) {
        viewModel.selectedBooks.value = []
        viewModel.selectedBooksCount.value = 0
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupPriceLabels()
    }
    
    func setupTableView() {
        
        tableView.register(UINib(nibName: "\(BookTableViewCell.self)", bundle: nil), forCellReuseIdentifier: "\(BookTableViewCell.self)")
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        
        tableView.rx.itemSelected
            .asObservable()
            .subscribe(onNext:{ indexPath in
                self.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted.asObservable().subscribe(onNext: {indexPath in
            self.viewModel.bookDeseleted.onNext(indexPath.row)
        }).disposed(by: disposeBag)
        
        viewModel.selectedBooks.asObservable().bind(to: tableView.rx.items(cellIdentifier: "\(BookTableViewCell.self)", cellType: BookTableViewCell.self)) { index, model, cell in
            cell.book = model
            
            }
            .disposed(by: disposeBag)
    }
    
    func setupPriceLabels() {
        
        viewModel.totalPrice().subscribe(onNext: { totalPrice in
            self.priceLabel.text = "\(totalPrice) €"
        }).disposed(by: disposeBag)
        
        viewModel.finalPrice()
            .subscribe(onNext: { finalPrice in
                self.finalPriceLabel.text = "\(finalPrice) €"
            }, onError: { error in
                self.finalPriceLabel.text = self.priceLabel.text
            })
            .disposed(by: disposeBag)
    }
}

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
    
    let disposeBag = DisposeBag()
    
    var viewModel: HPBooksViewModelType!
    
    @IBAction func validateAndPay(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Cart"
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
    }
    
    func setupPriceLabels() {
    }
}

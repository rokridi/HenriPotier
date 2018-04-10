//
//  BookTableViewCell.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 18/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import UIKit
import SDWebImage

protocol BookTableViewCellRepresentable {
    var bookVM: HPBookViewModelType! {get set}
}

class BookTableViewCell: UITableViewCell, BookTableViewCellRepresentable {
    
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var bookTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var bookVM: HPBookViewModelType! {
        didSet {
            bookTitleLabel.text = bookVM.title
            priceLabel.text = "\(bookVM.price) €"
            bookImageView.sd_setImage(with: URL(string: bookVM.cover))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

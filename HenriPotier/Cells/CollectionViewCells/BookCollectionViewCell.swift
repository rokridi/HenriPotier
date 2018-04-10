//
//  BookCollectionViewCell.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 18/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import UIKit
import SDWebImage

class BookCollectionViewCell: UICollectionViewCell, HPBookCollectionViewCellType {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    var bookVM: HPBookViewModelType! {
        didSet {
            refreshContent()
        }
    }
    
    override func prepareForReuse() {
        imageView.sd_cancelCurrentImageLoad()
    }
}

extension BookCollectionViewCell {
    private func refreshContent() {
        titleLabel.text = bookVM.title
        priceLabel.text = String(bookVM.price)
        imageView.sd_setImage(with: URL(string: bookVM.cover), placeholderImage: nil)
    }
}

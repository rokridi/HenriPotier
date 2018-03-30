//
//  BookCollectionViewCell.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 18/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import UIKit
import SDWebImage

protocol BookCollectionViewCellRepresentable {
    var book: HPBookViewModelType! {get set}
}

class BookCollectionViewCell: UICollectionViewCell, BookCollectionViewCellRepresentable {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    
    
    var book: HPBookViewModelType! {
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
        titleLabel.text = book.title
        priceLabel.text = String(book.price)
        imageView.sd_setImage(with: URL(string: book.cover), placeholderImage: nil)
    }
}

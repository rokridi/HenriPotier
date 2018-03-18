//
//  BookDetailViewController.swift
//  HenriPotier
//
//  Created by Mohamed Aymen Landolsi on 18/03/2018.
//  Copyright © 2018 Rokridi. All rights reserved.
//

import UIKit
import ParallaxHeader
import SDWebImage

protocol BookDetailViewControllerDelegate: class {
    func bookDetailViewController(_ viewController: BookDetailViewController, didAddBookToCart book: HPBookViewModelable)
    func bookDetailViewControllerDidDismiss(_ viewController: BookDetailViewController)
}

class BookDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView = UIImageView()
    let dismissButton = UIButton(type: .custom)
    
    var bookViewModel: HPBookViewModelable!
    weak var delegate: BookDetailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = bookViewModel.title
        self.priceLabel.text = "\(bookViewModel.price) €"
        self.synopsisLabel.text = bookViewModel.synopsis
        
        setupParallaxHeader()
    }
}

//MARK:- Actions

extension BookDetailViewController {
    
    @IBAction private func addToCart(_ sender: UIButton) {
        delegate?.bookDetailViewController(self, didAddBookToCart: bookViewModel)
        dismiss(animated: true, completion: nil)
    }
}
//MARK- Parallax

extension BookDetailViewController {
    
    private func setupParallaxHeader() {
        imageView.sd_setImage(with: URL(string: bookViewModel.cover), placeholderImage: nil) { (image, _, _, _) in
            
            DispatchQueue.main.async {
                guard let image = image else {return}
                let ratio = image.size.width / image.size.height
                self.scrollView.parallaxHeader.height = self.view.frame.size.width / ratio
            }
        }
        
        imageView.contentMode = .scaleAspectFill
        dismissButton.sizeToFit()
        scrollView.parallaxHeader.view = imageView
        scrollView.parallaxHeader.height = 0
        scrollView.parallaxHeader.minimumHeight = 0
        scrollView.parallaxHeader.mode = .centerFill
    }
}

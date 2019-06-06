//
//  CartInemTableViewCell.swift
//  simpl-demo-app-with-sdk-ios
//
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import UIKit

class CartInemTableViewCell: UITableViewCell {

    @IBOutlet weak var cartItemName: UILabel!
    @IBOutlet weak var cartItemQuantity: UILabel!
    @IBOutlet weak var cartItemStepper: UIStepper!
    
    weak var delegate: CartTableViewCellDelegate?
    var indexPath: IndexPath?
    
    @IBAction func cartItemStepper(_ sender: UIStepper) {
        cartItemQuantity.text = Int(sender.value).description
        delegate?.tappedStepper(on: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    var cartItem: Item? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        cartItemQuantity.text = cartItem?.quantity.description
    }

}

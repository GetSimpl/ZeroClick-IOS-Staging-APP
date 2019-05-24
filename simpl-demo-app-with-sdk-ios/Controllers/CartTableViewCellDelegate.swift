//
//  CartTableViewCellDelegate.swift
//  simpl-demo-app-with-sdk-ios
//
//  Created by Eleven on 20/05/19.
//  Copyright © 2019 Simpl Pay. All rights reserved.
//

import Foundation

protocol CartTableViewCellDelegate: class {
    func tappedStepper(on cell: CartInemTableViewCell)
}

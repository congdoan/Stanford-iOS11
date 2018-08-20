//
//  UIStackView+Ext.swift
//  SetGame
//
//  Created by Cong Doan on 8/20/18.
//  Copyright © 2018 Cong Doan. All rights reserved.
//

import UIKit

extension UIStackView {
    func removeAllSubviews() {
        for index in subviews.indices.reversed() {
            subviews[index].removeFromSuperview()
        }
    }
}

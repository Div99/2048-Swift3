
//
//  TileView.swift
//  2048
//
//  Created by Divyansh Garg on 11/23/16.
//  Copyright © 2016 Divyansh. All rights reserved.
//

import UIKit

class TileView : UICollectionViewCell {
    var value : Int = 0
    let delegate : AppearanceProviderProtocol!
    var numberLabel : UILabel!
            
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
  
    override init(frame: CGRect) {
        delegate = AppearanceProvider()
        super.init(frame: frame)
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.width))
        numberLabel.textAlignment = .center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNumbers()
        displayValue()
        addSubview(numberLabel)
        
    }
    
    func displayValue() {
        backgroundColor = delegate.tileColor(value: value)
        numberLabel.textColor = delegate.numberColor(value: value)
        numberLabel.text = value == 0 ? "" : "\(value)"
    
    }
    
    func setValue(v: Int){
        value = v
        displayValue()
        reloadInputViews()
    }
}

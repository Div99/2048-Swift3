
//
//  HeaderView.swift
//  2048
//
//  Created by Divyansh Garg on 11/29/16.
//  Copyright © 2016 Divyansh. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView{

    var scoreLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scoreLabel = UILabel(frame: CGRect(x: frame.width * 0.3, y: center.y * 0.5, width: 150, height: 50))
        scoreLabel.backgroundColor = .orange
        scoreLabel.layer.masksToBounds = true
        scoreLabel.layer.cornerRadius = 4
        scoreLabel.textColor = .blue
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        scoreLabel.text = "Score: 0"
        scoreLabel.isUserInteractionEnabled = true
       
        
        backgroundColor = UIColor(red: 0, green: 191 / 255.0, blue: 255.0 / 255.0, alpha: 1)
        addSubview(scoreLabel)
    }
    
    func setScore(score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

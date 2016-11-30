//
//  ViewController.swift
//  2048
//
//  Created by Divyansh Garg on 11/23/16.
//  Copyright © 2016 Divyansh. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
   
    
    var collectionview: UICollectionView!
    var headerview: HeaderView!
    var GameModel: Model!
    
    let auto = AutoMove()
    var tiles : [[TileView]] = []
    let radius: CGFloat = 3
    let slideTime: CGFloat = 0.2
    let flashTime: CGFloat = 0.1
    
    let tilePopMaxScale: CGFloat = 1.1
    
    let tileMergeExpandTime: TimeInterval = 0.08
    let tileMergeContractTime: TimeInterval = 0.08
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GameModel = Model()
        GameModel.addNewTile()
        tiles = Array(repeating: Array(repeating: TileView(), count: Model.size), count: Model.size)
        
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 100)

        collectionview = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        
        // Register cell classes
        collectionview.register(TileView.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionview.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView")

        collectionview.backgroundColor = .gray
        collectionview.dataSource = self
        collectionview.delegate = self
        
        view.addSubview(collectionview)
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showTile(tile: GameModel.initialTilePos)
        fillBackground()
    }
    
    func fillBackground() {
        for r in 0 ..< Model.size {
            for c in 0 ..< Model.size {
                let cell = tiles[r][c]
                let x = cell.frame.minX
                let y = cell.frame.minY
                let size = cell.frame.width
                let background = UIView(frame: CGRect(x: x, y: y, width: size, height: size))
                background.layer.cornerRadius = radius
                background.backgroundColor = .lightGray
                collectionview.addSubview(background)
                collectionview.sendSubview(toBack: background)
            }
        }
    }
    
    func showTile(tile: (Model.Location, Int)) {
        let cell = tiles[tile.0.row][tile.0.col]
        cell.setValue(v: tile.1)
    }
    
    func doMove(dx: Int, dy: Int) {
        let moves: [Model.Move] = GameModel.doMove(dx: dx, dy: dy)
        for m in moves {
            let origFrame = tiles[m.from.row][m.from.col].frame
            let finalFrame = tiles[m.to.row][m.to.col].frame
            
            UIView.animate(withDuration: TimeInterval(slideTime),
                                       delay: 0.0,
                                       animations: {
                                        // Slide tile
                                        self.tiles[m.from.row][m.from.col].frame = finalFrame
            },
                                       completion: { (finished: Bool) -> Void in
                                        self.displayTiles(m: m, f: origFrame)
                                        self.showNewTile()
                                        if(m.merge) {
                                            if(self.GameModel.tiles[m.to.row][m.to.col] == 2048) {
                                            self.userWon()
                                            }
                                            self.mergeAnimation(m: m)
                                        }
            })
     }
    }

    func displayTiles(m: Model.Move, f: CGRect) {

        let tile0 = tiles[m.from.row][m.from.col]
        let tile1 = tiles[m.to.row][m.to.col]
    
        tile0.setValue(v: self.GameModel.tile(r: m.from.row, c: m.from.col))
        tile1.setValue(v: self.GameModel.tile(r: m.to.row, c: m.to.col))
        tile0.frame = f
    }
    
    func showNewTile() {
        let r = GameModel.initialTilePos.0.row
        let c = GameModel.initialTilePos.0.col
        let tile = tiles[r][c]
        tile.setValue(v: GameModel.initialTilePos.1)
    }
    
    func mergeAnimation(m: Model.Move) {
        let tile = tiles[m.to.row][m.to.col]

        // Pop tile
        UIView.animate(withDuration: self.tileMergeExpandTime,
                                   animations: {
                                    tile.layer.setAffineTransform(CGAffineTransform(scaleX: self.tilePopMaxScale, y: self.tilePopMaxScale))
                                    self.headerview.setScore(score: self.GameModel.score)
        },
                                   completion: { finished in
                                    // Contract tile to original size
                                    UIView.animate(withDuration: self.tileMergeContractTime) {
                                        tile.layer.setAffineTransform(CGAffineTransform.identity)
                                    }
        })
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
         if(GameModel.gameOver) {
            gameOver()
        }
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                //print("Swiped right")
                doMove(dx: 1, dy: 0)
                break
            case UISwipeGestureRecognizerDirection.down:
                //print("Swiped down")
                doMove(dx: 0, dy: 1)
                break
            case UISwipeGestureRecognizerDirection.left:
                //print("Swiped left")
                doMove(dx: -1, dy: 0)
                break
            case UISwipeGestureRecognizerDirection.up:
               // print("Swiped up")
                doMove(dx: 0, dy: -1)
                break
            default:
                break
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 16
    }

    func userWon() {
        let alert = UIAlertController(title: "You are the king of the World", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Worthy", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.reset() }));
        alert.addAction(UIAlertAction(title: "Not worthy", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in exit(0) }));
        self.present(alert, animated: true, completion: nil)
    }
    
    func gameOver() {
        let alert = UIAlertController(title: "YOU LOST !!!", message: "Would you like to try again ?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in
            self.reset() }));
        alert.addAction(UIAlertAction(title: "Defeated", style: UIAlertActionStyle.default, handler: {(action:UIAlertAction) in exit(0) }));
        self.present(alert, animated: true, completion: nil)
    }
    
    func reset() {
        GameModel = Model()
        GameModel.addNewTile()
        headerview.setScore(score: 0)
        
        for r in 0 ..< Model.size {
            for c in 0 ..< Model.size {
                tiles[r][c].setValue(v: GameModel.tile(r: r, c: c))
            }
        }
        
    }
    
    func tapped() {
        let d = auto.bestMove(g: GameModel, depth: 2)
        if let a = d { 
            doMove(dx: a.dx, dy: a.dy)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TileView
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = radius
        
        let col = indexPath.item % 4
        let row = (indexPath.item - col) / 4
        tiles[row][col] = cell
       
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 70, left: 10, bottom: 0, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! HeaderView
        
        headerView.frame.size.height = 100
        headerview = headerView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        //tap.numberOfTapsRequired = 3
        headerView.scoreLabel.addGestureRecognizer(tap)
        
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let separator: CGFloat = 6.0 * 3.0
        let size = (view.frame.width - separator - 20) / 4.0
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
  
        return 6
    }

}

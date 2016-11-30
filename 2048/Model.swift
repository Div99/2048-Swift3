//
//  Model.swift
//  2048
//
//  Created by Divyansh Garg on 11/28/16.
//  Copyright © 2016 Divyansh. All rights reserved.
//

import UIKit

protocol GameModelProtocol : class {
    func scoreChanged(score: Int)
}

class Model: NSObject{
    
    var score: Int = 0
    //size of gameboard
    static var size = 4
    var tiles : [[Int]]
    var gameOver: Bool = false
    var initialTilePos: (Location, Int)
    
    override init() {
        tiles = Array(repeating: Array(repeating: 0, count: Model.size), count: Model.size)
        initialTilePos = (Location(r: 0, c: 0), 0)
    }
    
    class Location {
        var row: Int
        var col: Int
        
        init(r : Int, c: Int) {
            row = r
            col = c
        }
        
        // Create a location for (x,y) in the coordinate system where (dx, dy) is to the right
        init(x : Int, y: Int, dx: Int, dy: Int) {
        
        switch(2*dx + dy) {
        case 2:
            row = y
            col = x
            break
        case -2:
            row = y
            col = size - 1 - x
            break
        case 1:
            row = x
            col = y
            break
        case -1:
            row = size - 1 - x
            col = y
            break
        default:
            print("Error")
            row = -1
            col = -1
            break
        }
    }
}
    
    class Move {
        var from, to: Location
        var merge: Bool
        
        init(f: Location, t: Location, mrg: Bool) {
        from = f
        to = t
        merge = mrg
        }
    }
    
    func tile(loc: Location) -> Int {
        return tiles[loc.row][loc.col]
    }
    
    func tile(r: Int, c: Int) -> Int {
        return tiles[r][c]
    }
    
    /**
     Get tile to the right of (x,y)
    */
    func rtile(x: Int, y: Int, dx: Int, dy: Int) -> Int {
        let loc = Location(x: x, y: y, dx: dx, dy: dy)
        return tile(loc: loc)
    }
    
    /**
     Set tile to the right of (x,y)
     */
    func setrtile(x: Int, y: Int, dx: Int, dy: Int, v: Int) {
        let loc = Location(x: x, y: y, dx: dx, dy: dy)
        tiles[loc.row][loc.col] = v
    }
    
    /**
      Add a tile in a random blank space, and return true. The tile is 1 90% of
      the time and a 2 the remaining 10%. Return false if there is no blank
      space on the board. (Game Over)
     */
    func addNewTile() -> Bool {
        var numFree: Int = 0
        for r in 0 ..< Model.size {
            for c in 0 ..< Model.size {
                if (tiles[r][c] == 0) {
                    numFree += 1
                }
            }
        }
        if (numFree == 0) {
            return false
        }
        var i = Int(arc4random_uniform(UInt32(numFree)));
        for r in 0 ..< Model.size {
            for c in 0 ..< Model.size {
                if (tiles[r][c] == 0) {
                    i -= 1
                    if(i == -1){
                    tiles[r][c] = (arc4random_uniform(10) == 0) ? 4 : 2
                    let  loc = Location(r: r, c: c)
                    initialTilePos = (loc, tiles[r][c])
                    return true
                }
            }
            }
        }
        //can't get here
        return false
    }

    /**
     * Try to move the puzzle in the specified direction. Return a list of moves
     * performed if returnMoves is true, otherwise null. An empty list returned
     * means nothing could move.
     */
    func slideTiles(dx: Int, dy: Int) -> [Move] {
        var ret = [Move]()
        // only one merge can happen at a given location per turn.
        // fixed keeps track of the locations that have already merged.
        var fixed : [[Bool]] = Array(repeating: Array(repeating: false, count: Model.size), count: Model.size)
        for x in (0 ... (Model.size-2)).reversed() {
            for y in 0 ..< Model.size {
                let v = rtile(x: x, y: y, dx: dx, dy: dy)
                if( v != 0) {
                    var x1 = x + 1
                    while(x1 < Model.size && rtile(x: x1, y: y, dx: dx, dy: dy) == 0){
                        x1 += 1
                    }
                    if(x1 == Model.size) {
                        //move all way to edge
                        setrtile(x: x, y: y, dx: dx, dy: dy, v: 0)
                        setrtile(x: Model.size-1, y: y, dx: dx, dy: dy, v: v)
                        let loc = Location(x: x, y: y, dx: dx, dy: dy)
                        let loc1 = Location(x: Model.size - 1, y: y, dx: dx, dy: dy)
                        let move = Move(f: loc, t: loc1, mrg: false)
                        ret.append(move)
                    } else if(rtile(x: x1, y: y, dx: dx, dy: dy) == v && !fixed[x1][y]){
                        //slide and merge
                        setrtile(x: x, y: y, dx: dx, dy: dy, v: 0)
                        setrtile(x: x1, y: y, dx: dx, dy: dy, v: v*2)
                        score += v*2
                        fixed[x1][y] = true
                        let loc = Location(x: x, y: y, dx: dx, dy: dy)
                        let loc1 = Location(x: x1, y: y, dx: dx, dy: dy)
                        let move = Move(f: loc, t: loc1, mrg: true)
                        ret.append(move)
                    }
                    else if(x != x1 - 1) {
                        //slide upto next tile, no merge
                        setrtile(x: x, y: y, dx: dx, dy: dy, v: 0)
                        setrtile(x: x1-1, y: y, dx: dx, dy: dy, v: v)
                        let loc = Location(x: x, y: y, dx: dx, dy: dy)
                        let loc1 = Location(x: x1 - 1, y: y, dx: dx, dy: dy)
                        let move = Move(f: loc, t: loc1, mrg: false)
                        ret.append(move)
                    }
                }
            }
        }
        return ret
    }
    
    /**
     * Try to do a player move in direction (dx, dy), returning a list of tiles
     * moves that resulted, or an empty list if the move is not legal.
     */
    func doMove(dx: Int, dy: Int) -> [Move] {
        let moves: [Move] = slideTiles(dx: dx, dy: dy)
        if (!moves.isEmpty) {
            gameOver = !addNewTile()
        }
        return moves
    }
    
    func setTile(r: Int, c: Int, value: Int) {
        assert(value != 0)
        tiles[r][c] = value;
    }
    
    /** Make a deep copy of the game model, for use in searching. */
    func clone() -> Model {
    let g = Model()
    g.score = score
   // g.tiles = Array(repeating: Array(repeating: 0, count: Model.size), count: Model.size)
        for i in 0 ..< Model.size {
            for j in 0 ..< Model.size {
    g.tiles[i][j] = tiles[i][j]
            }
        }
    return g
    }

}

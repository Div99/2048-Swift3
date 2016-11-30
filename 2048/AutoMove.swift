//
//  AutoMove.swift
//  2048
//
//  Created by Divyansh Garg on 11/29/16.
//  Copyright © 2016 Divyansh. All rights reserved.
//

import UIKit

class AutoMove: NSObject {
    var dirs = [[Int]]()
    
    override init() {
         dirs = [[ 0, 1 ], [ 1, 0 ], [ 0, -1 ], [ -1, 0 ]]
    }
    
    class MoveChoice {
        var dx, dy: Int
        var heuristic: Int
        
        init(dx: Int, dy: Int, heuristic: Int) {
            self.dx = dx
            self.dy = dy
            self.heuristic = heuristic
        }
    }
    
     func averagePlacement(g2: Model, depth: Int, min:Int, max: Int) -> Int{
        assert (depth > 0)
        var sum = 0
        var num_empty = 0
        
        for r in 0 ..< Model.size {
            for c in 0 ..< Model.size {
                let g3 = g2.clone()
                if (g2.tile(r: r, c: c) != 0) {
                    continue
                }
                num_empty += 1
                for v in 1 ... 2 {
                    g3.setTile(r: r, c: c, value: v)
                   let  d = bestMove(g: g3, depth: depth - 1, min: min, max: max)
                    if (d == nil) {
                        sum += min
                    } else {
                        sum += d!.heuristic
                    }
                }
            }
        }
            if (num_empty == 0) {
                return min
            }
            else{
                return sum / 2 / num_empty
            }
    }
    
    func bestMove(g: Model, depth: Int, min: Int, max: Int) -> MoveChoice? {
        if(g.score == 0) {
            return MoveChoice(dx: 0, dy: 1, heuristic: 1)
        }
        var min = min
        var best: MoveChoice?
            for dir in  0 ..< 4 {
                let dx = dirs[dir][0]
                let dy = dirs[dir][1]
                let g2 = g.clone()
                let moves = g2.doMove(dx: dx, dy: dy)
                if (moves.isEmpty) {
                    continue
                }
                let gh = (depth > 0) ? averagePlacement(g2: g2, depth: depth, min: min, max: max)
                    : heuristic_score(g: g2)
                if (gh >= max) {
                    assert (gh != Int.max)
                    return MoveChoice(dx: dx, dy: dy, heuristic: max)
                }
                if (gh >= min) {
                    best = MoveChoice(dx: dx, dy: dy, heuristic: gh)
                    min = gh + 1
                }
            }
            return best
        }
    
    func bestMove(g: Model, depth: Int) -> MoveChoice? {
        let m = bestMove(g: g, depth: depth, min: -1, max: Int.max)
        
        if (m != nil) {
            print("Empty cells: \(num_empty_cells(g: g)), clustering score \(clustering_score(g: g))")
            print("Best move:  \(m!.heuristic)")
        }
        return m
    }
    
        func heuristic_score(g: Model)-> Int {
            let rs = Double(g.score)
            let ec = Double(num_empty_cells(g: g))
            let cs = Double(clustering_score(g: g))
            let n = log(rs) + 2
            let h = Int(rs + n * ec - cs)
            return max(h, min(Int(rs), 1))
        }
        
        func num_empty_cells(g: Model) -> Int {
            var ret = 0
            for i in 0 ..< Model.size {
                for j in 0 ..< Model.size {
                    if (g.tile(r: i, c: j) == 0) {
                        ret += 1
                    }
                }
            }
            return ret
        }
        
       func clustering_score(g: Model) -> Int{
            var ret = 0
            // clustering score is the sum of the individual clustering
            // scores for the occupied tiles
            for i in 0 ..< Model.size {
                for j in 0 ..< Model.size {
                    if (g.tile(r: i, c: j) != 0) {
                        ret += cell_clustering_score(g: g, i: i, j: j)
                    }
                }
            }
            return ret
        }
     
        func cell_clustering_score(g: Model, i: Int, j: Int) -> Int {
            let v = g.tile(r: i, c: j)
            let n = Model.size
            assert (v != 0)
            var sum1 = 0
            var sum2 = 0
            var saw_smaller = false
            var saw_bigger = false
            for d in 0 ..< 4 {
                let x = i + dirs[d][0]
                let y = j + dirs[d][1]
                if (x < 0 || x >= n || y <= 0 || y >= n) {
                    continue
                }
                let v2 = g.tile(r: x, c: y)
                if (v2 == 0) {
                    sum2 += v / 8
                    continue
                }
                
                if (v2 + v2 == v && !saw_smaller) {
                    saw_smaller = true
                }
                else if (v + v == v2 && !saw_bigger) {
                    saw_bigger = true
                } else {
                    if (v2 + v2 == v)  {
                        sum2 += v2
                    }
                    else if (v + v == v2) {
                        sum2 += v
                    }
                    else {
                        sum1 += abs(v - v2)
                    }
                }
            }
            if (saw_smaller) {
                return sum2
            }
            return sum1 + sum2
        }
        
}

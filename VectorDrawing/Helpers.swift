//
//  Helpers.swift
//  VectorDrawing
//
//  Created by Chris Eidhof on 22.02.21.
//

import Foundation

extension CGPoint {
    func mirrored(relativeTo p: CGPoint) -> CGPoint {
        let relative = self - p
        return p - relative
    }
    
    func distance(to: CGPoint) -> CGFloat {
        sqrt(pow(to.x - x, 2) + pow(to.y - y, 2))
    }
        
    static prefix func -(rhs: CGPoint) -> CGPoint {
        CGPoint(x: -rhs.x, y: -rhs.y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.width)
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        lhs + (-rhs)
    }
    
    func rounded() -> CGPoint {
        return CGPoint(x: x.rounded(), y: y.rounded())
    }
}

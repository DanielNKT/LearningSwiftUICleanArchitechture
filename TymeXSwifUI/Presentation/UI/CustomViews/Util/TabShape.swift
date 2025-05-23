//
//  TabShape.swift
//  TymeXSwifUI
//
//  Created by Bé Gạo on 23/5/25.
//

import SwiftUI

struct TabShape: Shape {
    var midPoint: CGFloat
    
    /// Adding TabShape Animation
    var animatableData: CGFloat {
        get { midPoint }
        set { midPoint = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        /// First: Draw the Rectangle shape
        path.addPath(Rectangle().path(in: rect))
        /// Second: Draw upward Curve shape
        path.move(to: .init(x: midPoint - 60, y: 0))
        
        /// Draw up
        let to = CGPoint(x: midPoint, y: -25)
        
        let control1 = CGPoint(x: midPoint - 25, y: 0)
        let control2 = CGPoint(x: midPoint - 25, y: -25)
        
        path.addCurve(to: to, control1: control1, control2: control2)
        
        /// Draw down
        let to1 = CGPoint(x: midPoint + 60, y: 0)
        
        let control3 = CGPoint(x: midPoint + 25, y: -25)
        let control4 = CGPoint(x: midPoint + 25, y: 0)
        
        path.addCurve(to: to1, control1: control3, control2: control4)
        
        return path
    }
}

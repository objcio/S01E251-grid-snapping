//
//  CodeGeneration.swift
//  VectorDrawing
//
//  Created by Chris Eidhof on 14.04.21.
//

import SwiftUI

extension CGPoint {
    var code: String {
        "CGPoint(x: \(x), y: \(y))"
    }
}

extension Path.Element {
    var code: String {
        switch self {
        case .move(to: let to):
            return "p.move(to: \(to.code))"
        case .line(to: let to):
            return "p.addLine(to: \(to.code))"
        case .quadCurve(to: let to, control: let control):
            return "p.addQuadCurve(to: \(to), control: \(control))"
        case .curve(to: let to, control1: let control1, control2: let control2):
            return "p.addCurve(to: \(to), control1: \(control1), control2: \(control2))"
        case .closeSubpath:
            return "p.closeSubpath()"
        }
    }
}

extension Path {
    var code: String {
        guard !isEmpty else { return "Path()" }
        var result = "Path { p in\n"
        forEach { element in
            result.append("    \(element.code)\n")
        }
        result.append("}")
        return result
    }
}

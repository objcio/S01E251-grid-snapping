//
//  ContentView.swift
//  VectorDrawing
//
//  Created by Chris Eidhof on 22.02.21.
//

import SwiftUI

struct PathPoint: View {
    @Binding var element: Drawing.Element
    var selected: Bool
    var drawControlPoints: Bool
    var grid: CGSize?
    var select: (_ exclusively: Bool) -> ()
    var move: (CGPoint) -> ()
    
    func pathPoint(at: CGPoint) -> some View {
        let click = TapGesture()
            .onEnded { select(true) }
        let shiftClick = TapGesture()
            .modifiers(.shift)
            .onEnded { select(false) }
        let doubleClick = TapGesture(count: 2)
            .onEnded { element.resetControlPoints() }
        let drag = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .onChanged {
                if !selected { select(true) }
                move($0.location)
            }
        let optionDrag = DragGesture(minimumDistance: 1, coordinateSpace: .local)
            .modifiers(.option)
            .onChanged {
                if !selected { select(true) }
                element.setCoupledControlPoints(secondary: $0.location)
            }
        return Circle()
            .stroke(selected ? Color.blue : .black, lineWidth: selected ? 2 : 1)
            .background(Circle().fill(Color.white))
            .padding(2)
            .frame(width: 14, height: 14)
            .offset(x: at.x-7, y: at.y-7)
            .gesture(optionDrag.exclusively(before: drag).simultaneously(with: doubleClick.simultaneously(with: shiftClick.exclusively(before: click))))
    }

    func controlPoint(at: CGPoint, move: @escaping (CGPoint, _ option: Bool) -> ()) -> some View {
        let moveGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { move($0.location, false) }
        let optionMoveGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .modifiers(.option)
            .onChanged { move($0.location, true) }
        return RoundedRectangle(cornerRadius: 2)
            .stroke(Color.black)
            .background(RoundedRectangle(cornerRadius: 2).fill(Color.white))
            .padding(4)
            .frame(width: 14, height: 14)
            .offset(x: at.x-7, y: at.y-7)
            .gesture(optionMoveGesture.exclusively(before: moveGesture))
    }

    var body: some View {
        if let cp = element.controlPoints, drawControlPoints {
            Path { p in
                p.move(to: cp.0)
                p.addLine(to: element.point)
                p.addLine(to: cp.1)
            }.stroke(Color.gray)
            controlPoint(at: cp.0) { p, option in
                element.moveControlPoint1(to: p, grid: grid, option: option)
            }
            controlPoint(at: cp.1) { p, option in
                element.moveControlPoint2(to: p, grid: grid, option: option)
            }
        }
        pathPoint(at: element.point)
    }
}

struct Points: View {
    @Binding var drawing: Drawing
    
    var body: some View {
        let lastId = drawing.elements.last?.id
        ForEach(Array(zip(drawing.elements, drawing.elements.indices)), id: \.0.id) { pair in
            let element = pair.0
            let id = element.id
            let selected = drawing.selection.contains(id)
            let drawControlPoints = (id == lastId && drawing.selection.isEmpty) || selected
            PathPoint(element: $drawing.elements[pair.1], selected: selected, drawControlPoints: drawControlPoints, grid: drawing.grid, select: { exclusive in
                drawing.select(id, exclusive: exclusive)
            }, move: { to in
                let rel = to - element.point
                drawing.move(by: rel, snap: true)
            })
        }
    }
}

struct GridShape: Shape {
    var grid: CGSize
    
    func path(in rect: CGRect) -> Path {
        Path { p in
            for y in stride(from: 0, to: rect.maxY, by: grid.height) {
                p.move(to: CGPoint(x: rect.minX, y: y))
                p.addLine(to: CGPoint(x: rect.maxX, y: y))
            }
            for x in stride(from: 0, to: rect.maxX, by: grid.width) {
                p.move(to: CGPoint(x: x, y: rect.minY))
                p.addLine(to: CGPoint(x: x, y: rect.maxY))
            }
        }
    }
}

struct DrawingView: View {
    @Binding var drawing: Drawing
    @GestureState var currentDrag: DragGesture.Value? = nil
    @Environment(\.flags) var flags
    
    var liveDrawing: Drawing {
        var copy = drawing
        if let state = currentDrag {
            copy.update(for: state)
        }
        return copy
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.white
                .focusable()
                .opacity(0)
                .onMoveCommand(perform: { drawing.moveKeyCommand($0, shiftPressed: flags.contains(.shift)) })
                .onDeleteCommand { drawing.delete() }
            Color.white
            if let grid = drawing.grid {
                GridShape(grid: grid)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color(white: 0.9))
            }
            liveDrawing.path.stroke(Color.black, lineWidth: 2)
            Points(drawing: Binding(get: { liveDrawing }, set: { drawing = $0 }))
        }
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .updating($currentDrag, body: { (value, state, _) in
                    state = value
                })
                .onChanged { _ in
                    drawing.selection = []
                }
                .onEnded { state in
                    drawing.update(for: state)
                }
        )
    }
}

struct FlagsKey: EnvironmentKey {
    static let defaultValue: NSEvent.ModifierFlags = []
}

extension EnvironmentValues {
    var flags: NSEvent.ModifierFlags {
        get { self[FlagsKey.self] }
        set { self[FlagsKey.self] = newValue }
    }
}

struct ContentView: View {
    @State var drawing = Drawing()
    var flags: NSEvent.ModifierFlags = []
    
    var body: some View {
        VStack {
            DrawingView(drawing: $drawing)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                Text(drawing.path.code)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: 150)
            .background(Color(.windowBackgroundColor))
        }
        .environment(\.flags, flags)
        .background(Color.white)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

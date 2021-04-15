//
//  AppDelegate.swift
//  VectorDrawing
//
//  Created by Chris Eidhof on 22.02.21.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        let hostingView = MyHostingView(rootView: contentView)
        window.contentView = hostingView
        hostingView.onFlagsChanged = { [unowned hostingView] in
            hostingView.rootView.flags = $0
        }
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

final class MyHostingView<C: View>: NSHostingView<C> {
    var onFlagsChanged: ((NSEvent.ModifierFlags) -> ())?
    override func flagsChanged(with event: NSEvent) {
        onFlagsChanged?(event.modifierFlags)
    }
}


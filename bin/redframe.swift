// redframe: a red border around every screen while Claude controls the desktop. Click-through; exits by itself after N seconds.
import Cocoa
let seconds = Double(CommandLine.arguments.dropFirst().first ?? "") ?? 180
final class Frame: NSView {
    override func draw(_ r: NSRect) {
        NSColor.systemRed.setStroke()
        let p = NSBezierPath(rect: bounds.insetBy(dx: 1.5, dy: 1.5)); p.lineWidth = 3; p.stroke()
    }
}
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
var wins: [NSWindow] = []
for s in NSScreen.screens {
    let w = NSWindow(contentRect: s.frame, styleMask: .borderless, backing: .buffered, defer: false)
    w.backgroundColor = .clear; w.isOpaque = false; w.hasShadow = false; w.ignoresMouseEvents = true
    w.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 5)
    w.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
    w.contentView = Frame(frame: NSRect(origin: .zero, size: s.frame.size))
    w.orderFrontRegardless(); wins.append(w)
}
DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { exit(0) }
app.run()

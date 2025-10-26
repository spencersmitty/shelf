//
//  FileDropView.swift
//  Shelf
//
//  Created by spencer smith on 23/10/2025.
//

import Cocoa

class FileDropView: NSView {
    var onFilesDropped: (([URL]) -> Void)?

    let hintLabel = NSTextField(labelWithString: "Drag files here")
    let iconView = NSImageView(image: NSImage(systemSymbolName: "doc.text", accessibilityDescription: "File") ?? NSImage())

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.borderColor = NSColor.separatorColor.cgColor
        layer?.borderWidth = 1

        hintLabel.alignment = .center
        hintLabel.textColor = .secondaryLabelColor

        iconView.symbolConfiguration = .init(pointSize: 28, weight: .regular)
        iconView.contentTintColor = .tertiaryLabelColor
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hintLabel)
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),

            hintLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        layer?.borderColor = NSColor.systemBlue.cgColor
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        layer?.borderColor = NSColor.separatorColor.cgColor
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        layer?.borderColor = NSColor.separatorColor.cgColor
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] else { return false }
        onFilesDropped?(urls)
        return true
    }
    func showHint(_ visible: Bool) {
        hintLabel.isHidden = !visible
        iconView.isHidden = !visible
    }
}


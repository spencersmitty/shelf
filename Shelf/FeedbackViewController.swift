//
//  FileDropView.swift
//  Shelf
//
//  Created by spencer smith on 23/10/2025.
//

import Cocoa

class FeedbackViewController: NSViewController {

    @IBOutlet weak var fileDropView: FileDropView!
    @IBOutlet weak var messageScrollView: NSScrollView!
    @IBOutlet weak var messageTextView: NSTextView!
    private var stackView: NSStackView?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFileListArea()
        fileDropView.setHintVisible(true)
        
        // make sure the text box looks modern + system consistent
        if let textView = messageTextView {
            textView.font = .systemFont(ofSize: 13)
            textView.textColor = .labelColor
            textView.backgroundColor = .textBackgroundColor
            textView.textContainer?.lineFragmentPadding = 6
            textView.textContainerInset = NSSize(width: 4, height: 6)
            
            textView.wantsLayer = true
            textView.layer?.cornerRadius = 8
            textView.layer?.masksToBounds = true
            textView.layer?.borderWidth = 1
            textView.layer?.borderColor = NSColor.separatorColor.cgColor

            textView.enclosingScrollView?.hasVerticalScroller = true
            textView.enclosingScrollView?.autohidesScrollers = true
        }

        // connect file drop behavior to ui
        fileDropView.onFilesDropped = { [weak self] urls in
            guard let self = self else { return }
            self.fileDropView.setHintVisible(false)
            for url in urls {
                self.addFileRow(for: url)
            }
        }
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.view.window?.close()
    }

    func setupFileListArea() {
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .legacy
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.contentInsets = NSEdgeInsetsZero

        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.edgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        scrollView.documentView = stackView
        fileDropView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: fileDropView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: fileDropView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: fileDropView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: fileDropView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: scrollView.bottomAnchor)
        ])

        self.stackView = stackView
    }

    func addFileRow(for fileURL: URL) {
        guard let stackView = stackView else { return }

        let fileRow = NSStackView()
        fileRow.orientation = .horizontal
        fileRow.alignment = .centerY
        fileRow.spacing = 8
        fileRow.edgeInsets = NSEdgeInsets(top: 6, left: 10, bottom: 6, right: 16)
        fileRow.translatesAutoresizingMaskIntoConstraints = false
        fileRow.heightAnchor.constraint(equalToConstant: 36).isActive = true

        let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
        icon.size = NSSize(width: 20, height: 20)
        let iconView = NSImageView(image: icon)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.imageScaling = .scaleProportionallyUpOrDown

        let fileLabel = NSTextField(labelWithString: fileURL.lastPathComponent)
        fileLabel.font = .systemFont(ofSize: 13)
        fileLabel.textColor = .labelColor
        fileLabel.lineBreakMode = .byTruncatingMiddle

        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let spacer = NSView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let trashImage = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove") ?? NSImage(named: NSImage.stopProgressTemplateName) ?? NSImage()
        let removeButton = NSButton(image: trashImage, target: self, action: #selector(removeFile(_:)))
        removeButton.isBordered = false
        removeButton.contentTintColor = .secondaryLabelColor
        removeButton.identifier = NSUserInterfaceItemIdentifier(fileURL.path)
        removeButton.imagePosition = .imageOnly
        removeButton.setContentHuggingPriority(.required, for: .horizontal)
        removeButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        fileRow.addArrangedSubview(iconView)
        fileRow.addArrangedSubview(fileLabel)
        fileRow.addArrangedSubview(spacer)
        fileRow.addArrangedSubview(removeButton)

        fileLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let divider = NSBox()
        divider.boxType = .custom
        divider.borderColor = .separatorColor
        divider.borderWidth = 1
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        // Always add a divider before adding the next row except when the stack is empty, then add divider after too
        if stackView.arrangedSubviews.isEmpty {
            // First item: add the row, then a divider so it visually matches subsequent items
            stackView.addArrangedSubview(fileRow)
            stackView.addArrangedSubview(divider)
        } else {
            // Subsequent items: remove trailing divider if any inconsistency, then add row and a divider
            stackView.addArrangedSubview(fileRow)
            let newDivider = NSBox()
            newDivider.boxType = .custom
            newDivider.borderColor = .separatorColor
            newDivider.borderWidth = 1
            newDivider.translatesAutoresizingMaskIntoConstraints = false
            newDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true
            stackView.addArrangedSubview(newDivider)
        }
    }

    @objc func removeFile(_ sender: NSButton) {
        guard let fileRow = sender.superview as? NSStackView,
              let stackView = stackView else { return }

        if let index = stackView.arrangedSubviews.firstIndex(of: fileRow) {
            fileRow.removeFromSuperview()
            if index < stackView.arrangedSubviews.count {
                let nextView = stackView.arrangedSubviews[index]
                if nextView is NSBox { nextView.removeFromSuperview() }
            }
        }

        if stackView.arrangedSubviews.isEmpty {
            fileDropView.setHintVisible(true)
        }
    }
}

extension FileDropView {
    func setHintVisible(_ visible: Bool) {
        showHint(visible)
    }
}

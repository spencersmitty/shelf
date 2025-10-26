//
//  ContentView.swift
//  shelf
//
//  Created by spencer smith on 22/10/2025.
//

import SwiftUI
import UniformTypeIdentifiers

#if canImport(UIKit)
private extension Image {
    // Returns non-nil if an image with this name exists in the asset catalog on UIKit platforms
    static func uiImageNamed(_ name: String) -> UIImage? { UIImage(named: name) }
}
#else
import AppKit
private extension Image {
    // Returns non-nil if an image with this name exists in the asset catalog on AppKit platforms
    static func nsImageNamed(_ name: String) -> NSImage? { NSImage(named: name) }
}
#endif

struct Console: Identifiable, Hashable {
    let id: String
    let displayName: String
    let systemImage: String
}

struct Game: Identifiable, Hashable {
    let id: UUID
    let title: String
    let fileURL: URL

    init(id: UUID = UUID(), title: String, fileURL: URL) {
        self.id = id
        self.title = title
        self.fileURL = fileURL
    }
}

// Special sidebar destinations
enum LibrarySection: String, Identifiable, Hashable {
    case recents
    case all
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .recents: return "Recents"
        case .all: return "All Games"
        }
    }
    var systemImage: String {
        switch self {
        case .recents: return "clock"
        case .all: return "tray.full"
        }
    }
}

enum SidebarSelection: Hashable {
    case section(LibrarySection)
    case console(Console)
}

let consoles = [
    Console(id: "ps", displayName: "Sony PlayStation", systemImage: "playstation.logo"),
    Console(id: "ps2", displayName: "Sony PlayStation 2", systemImage: "playstation.logo"),
    Console(id: "snes", displayName: "Super Nintendo Entertainment System", systemImage: "gamecontroller"),
    Console(id: "n64", displayName: "Nintendo 64", systemImage: "gamecontroller"),
    Console(id: "nes", displayName: "Nintendo Entertainment System", systemImage: "gamecontroller"),
    Console(id: "gb", displayName: "Game Boy", systemImage: "gamecontroller"),
    Console(id: "gbc", displayName: "Game Boy Color", systemImage: "gamecontroller"),
    Console(id: "gba", displayName: "Game Boy Advance", systemImage: "gamecontroller"),
    Console(id: "gcn", displayName: "Nintendo GameCube", systemImage: "cube"),
    Console(id: "dc", displayName: "Sega Dreamcast", systemImage: "gamecontroller"),
    Console(id: "nds", displayName: "Nintendo DS", systemImage: "gamecontroller"),
    Console(id: "md", displayName: "Sega Mega Drive", systemImage: "gamecontroller")
]

struct ContentView: View {
    @State private var selection: SidebarSelection? = .section(.all)
    @State private var searchText: String = ""
    @State private var isDraggingOverEmpty: Bool = false
    @State private var viewMode: Int = 0 // 0: icons, 1: list, 2: columns
    @State private var gamesByConsole: [String: [Game]] = [:]
    
    private let sidebarIconSize: CGFloat = 16

    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder
    private func ConsoleRowLabel(_ console: Console) -> some View {
        HStack(spacing: 8) {
            ZStack(alignment: .center) {
                Color.clear
                if platformHasAsset(named: console.id) {
                    Image(console.id)
                        .renderingMode(.template)
                        .resizable()
                        .interpolation(.medium)
                        .scaledToFit()
                        .frame(width: sidebarIconSize + 2, height: sidebarIconSize + 2)
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                } else {
                    Image(systemName: console.systemImage)
                        .renderingMode(.template)
                        .font(.system(size: sidebarIconSize))
                        .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                }
            }
            .frame(width: 22, alignment: .center) // centered gutter so icons line up

            Text(console.displayName)
        }
    }

    private func platformHasAsset(named name: String) -> Bool {
        #if canImport(UIKit)
        return Image.uiImageNamed(name) != nil
        #else
        return Image.nsImageNamed(name) != nil
        #endif
    }
    

    #if os(macOS)
    private var sidebarMaxWidth: CGFloat {
        let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let longest = consoles.map { $0.displayName }.max(by: { $0.count < $1.count }) ?? ""
        let textWidth = (longest as NSString).size(withAttributes: attributes).width
        // icon (~18) + spacing (8) + leading inset (20) + trailing inset (12) + extra padding (20)
        return textWidth + 18 + 8 + 20 + 12 + 20
    }
    #endif

    // Games for the selected console or section
    var filteredGames: [Game] {
        if let selection {
            switch selection {
            case .section(let sec):
                switch sec {
                case .all:
                    let all = gamesByConsole.values.flatMap { $0 }
                    return Array(all)
                case .recents:
                    let flattened = gamesByConsole.values.flatMap { $0 }
                    let recent = flattened.suffix(10)
                    return Array(recent)
                }
            case .console(let con):
                return gamesByConsole[con.id] ?? []
            }
        }
        return []
    }
    
    private var titleForSelection: String {
        switch selection {
        case .section(let sec):
            return sec.displayName
        case .console(let con):
            return con.displayName
        case .none:
            return ""
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Section("Library") {
                    NavigationLink(
                        value: SidebarSelection.section(.recents),
                        label: {
                            HStack(spacing: 8) {
                                ZStack {
                                    Color.clear
                                    Image(systemName: LibrarySection.recents.systemImage)
                                        .font(.system(size: sidebarIconSize))
                                }
                                .frame(width: 22, alignment: .center)

                                Text(LibrarySection.recents.displayName)
                            }
                        }
                    )
                    NavigationLink(
                        value: SidebarSelection.section(.all),
                        label: {
                            HStack(spacing: 8) {
                                ZStack {
                                    Color.clear
                                    Image(systemName: LibrarySection.all.systemImage)
                                        .font(.system(size: sidebarIconSize))
                                }
                                .frame(width: 22, alignment: .center)

                                Text(LibrarySection.all.displayName)
                            }
                        }
                    )
                }
                Section("Consoles") {
                    ForEach(consoles) { console in
                        NavigationLink(
                            value: SidebarSelection.console(console),
                            label: {
                                ConsoleRowLabel(console)
                            }
                        )
                    }
                }
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: sidebarMaxWidth)
#endif
            .tint(.accentColor)
            .listStyle(.sidebar)
        } detail: {
            VStack(spacing: 0) {
                let gridColumns: [GridItem] = [
                    GridItem(.adaptive(minimum: 140), spacing: 16)
                ]
                if filteredGames.isEmpty {
                    // Empty State
                    VStack(spacing: 24) {
                        Image(systemName: isDraggingOverEmpty ? "plus.circle.fill" : "opticaldisc")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .foregroundStyle(isDraggingOverEmpty ? AnyShapeStyle(.green) : AnyShapeStyle(.quaternary))
                        Text(isDraggingOverEmpty ? "Add to Library" : "No games yet")
                            .font(.title2).bold()
                            .foregroundStyle(.secondary)
                        Text(isDraggingOverEmpty ? "Drop files to add them." : "Drag games here to add them.")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDraggingOverEmpty) { providers in
                        handleDrop(providers)
                    }
                } else {
                    switch viewMode {
                    case 0: // Grid view
                        ScrollView {
                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(filteredGames) { game in
                                    VStack(alignment: .leading, spacing: 8) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(.quaternary)
                                                .frame(height: 120)
                                            Image(systemName: "opticaldisc")
                                                .font(.system(size: 40))
                                                .foregroundStyle(.tertiary)
                                        }
                                        Text(game.title)
                                            .font(.body)
                                            .lineLimit(2)
                                    }
                                    .padding(8)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            .padding(16)
                        }
                        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDraggingOverEmpty) { providers in
                            handleDrop(providers)
                        }
                    case 1: // List view
                        List {
                            ForEach(filteredGames) { game in
                                HStack(spacing: 12) {
                                    Image(systemName: "opticaldisc")
                                        .foregroundStyle(.secondary)
                                    VStack(alignment: .leading) {
                                        Text(game.title)
                                        Text(game.fileURL.lastPathComponent)
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                        }
                        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDraggingOverEmpty) { providers in
                            handleDrop(providers)
                        }
                    default: // 2: Shelf view placeholder
                        VStack(spacing: 12) {
                            Image(systemName: "books.vertical")
                                .font(.system(size: 48))
                                .foregroundStyle(.tertiary)
                            Text("Shelf view coming soon")
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isDraggingOverEmpty) { providers in
                            handleDrop(providers)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(titleForSelection)
#if os(iOS) || os(tvOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // View toggle segmented control
                Picker("View", selection: $viewMode) {
                    Image(systemName: "square.grid.2x2").tag(0) // Icon view
                    Image(systemName: "list.bullet").tag(1)    // List view
                    Image(systemName: "rectangle.split.3x1").tag(2) // Columns view
                }
                .pickerStyle(.segmented)

                // Search field
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 240)
            }
        }
#if os(macOS)
        .toolbarBackground(.hidden, for: .windowToolbar)
        .toolbar(.visible)
#endif
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        var handled = false
        let fileUTI = UTType.fileURL.identifier
        for provider in providers where provider.hasItemConformingToTypeIdentifier(fileUTI) {
            provider.loadItem(forTypeIdentifier: fileUTI, options: nil) { (item, error) in
                guard error == nil else { return }

                // Handle URL directly
                if let url = item as? URL {
                    addGame(from: url)
                    return
                }

                // Handle Data representing a bookmark or file URL
                if let data = item as? Data {
                    // Try to create a URL via dataRepresentation first
                    if let url = URL(dataRepresentation: data, relativeTo: nil) {
                        addGame(from: url)
                        return
                    }

                    // Fallback: try resolving as bookmark data (requires inout Bool, not nil)
                    var isStale = false
                    if let url = try? URL(resolvingBookmarkData: data, options: [], bookmarkDataIsStale: &isStale) {
                        addGame(from: url)
                        return
                    }
                }
            }
            handled = true
        }
        return handled
    }

    private func addGame(from url: URL) {
        guard case let .console(console)? = selection else { return }
        let title = url.deletingPathExtension().lastPathComponent
        let game = Game(title: title, fileURL: url)
        DispatchQueue.main.async {
            var games = gamesByConsole[console.id] ?? []
            if !games.contains(game) {
                games.append(game)
                gamesByConsole[console.id] = games
            }
        }
    }
}

#Preview {
    ContentView()
}


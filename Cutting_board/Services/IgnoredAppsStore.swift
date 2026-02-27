//
//  IgnoredAppsStore.swift
//  Cutting_board
//
//  忽略应用程序列表：不保存从这些应用复制的内容
//

import AppKit
import Combine
import Foundation
import SwiftUI
import UniformTypeIdentifiers

private let userDefaultsKey = "Cutting_board.ignoredBundleIDs"

final class IgnoredAppsStore: ObservableObject {
    static let shared = IgnoredAppsStore()

    @Published private(set) var bundleIDs: [String] = [] {
        didSet { UserDefaults.standard.set(bundleIDs, forKey: userDefaultsKey) }
    }

    private init() {
        bundleIDs = UserDefaults.standard.stringArray(forKey: userDefaultsKey) ?? []
    }

    func add(bundleID: String) {
        guard !bundleID.isEmpty, !bundleIDs.contains(bundleID) else { return }
        bundleIDs.append(bundleID)
    }

    func remove(bundleID: String) {
        bundleIDs.removeAll { $0 == bundleID }
    }

    func contains(_ bundleID: String?) -> Bool {
        guard let id = bundleID else { return false }
        return bundleIDs.contains(id)
    }
}

// MARK: - 从 Bundle ID 取应用名与图标

enum AppInfoHelper {
    static func name(for bundleID: String) -> String {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID),
              let bundle = Bundle(url: url),
              let info = bundle.infoDictionary else { return bundleID }
        return (info["CFBundleDisplayName"] as? String) ?? (info["CFBundleName"] as? String) ?? bundleID
    }

    static func icon(for bundleID: String) -> NSImage? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else { return nil }
        return NSWorkspace.shared.icon(forFile: url.path)
    }

    /// 用 NSOpenPanel 选择 .app，返回 bundleIdentifier
    static func pickApplicationBundleID() -> String? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        guard panel.runModal() == .OK, let url = panel.url else { return nil }
        return Bundle(url: url)?.bundleIdentifier
    }
}

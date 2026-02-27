//
//  ClipboardStore.swift
//  Cutting_board
//
//  剪贴板监控与历史本地存储
//

import AppKit
import Combine
import Foundation
import SwiftUI

/// 剪贴板历史存储与监控
final class ClipboardStore: ObservableObject {
    static let shared = ClipboardStore()

    /// 历史记录（最新在前）
    @Published private(set) var items: [ClipboardItem] = []

    /// 最大保留条数
    var maxItems: Int = 999 {
        didSet { trimIfNeeded() }
    }

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int = -1
    private var timer: Timer?
    private let storageURL: URL
    private let queue = DispatchQueue(label: "Cutting_board.storage", qos: .userInitiated)

    private init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("Cutting_board", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        storageURL = dir.appendingPathComponent("history.json", isDirectory: false)
        loadFromDisk()
        lastChangeCount = pasteboard.changeCount
        startMonitoring()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - 监控

    private func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func checkPasteboard() {
        let count = pasteboard.changeCount
        guard count != lastChangeCount else { return }
        lastChangeCount = count
        captureCurrentContent()
    }

    private static let ignoredBundleIDsKey = "Cutting_board.ignoredBundleIDs"

    /// 将当前系统剪贴板内容加入历史
    private func captureCurrentContent() {
        if let front = NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
           (UserDefaults.standard.stringArray(forKey: Self.ignoredBundleIDsKey) ?? []).contains(front) {
            return
        }
        // 优先尝试图片
        if let image = NSImage(pasteboard: pasteboard),
           let tiff = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            let base64 = pngData.base64EncodedString()
            let item = ClipboardItem(
                content: "[图片]",
                type: .image,
                imageDataBase64: base64
            )
            addItem(item)
            return
        }

        // 文本
        if let string = pasteboard.string(forType: .string), !string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let item = ClipboardItem(content: string, type: .text)
            addItem(item)
        }
    }

    // MARK: - 增删

    private func addItem(_ item: ClipboardItem) {
        if let first = items.first,
           first.content == item.content && first.type == item.type,
           item.type != .image || first.imageDataBase64 == item.imageDataBase64 {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let pinnedCount = self.items.filter(\.isPinned).count
            self.items.insert(item, at: pinnedCount)
            self.trimIfNeeded()
            self.saveToDisk()
        }
    }

    private func trimIfNeeded() {
        let pinned = items.filter(\.isPinned)
        let unpinned = items.filter { !$0.isPinned }
        let keepCount = max(0, maxItems - pinned.count)
        items = pinned + Array(unpinned.prefix(keepCount))
    }

    /// 钉住/取消钉住
    func togglePin(_ item: ClipboardItem) {
        updateItem(id: item.id) { $0.isPinned.toggle() }
        sortPinnedFirst()
        saveToDisk()
    }

    /// 更新备注
    func updateRemark(_ item: ClipboardItem, remark: String?) {
        let trimmed = remark?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateItem(id: item.id) { $0.remark = trimmed?.isEmpty == true ? nil : trimmed }
        saveToDisk()
    }

    /// 更新内容（仅支持文本类型）
    func updateContent(_ item: ClipboardItem, content: String) {
        guard item.type == .text else { return }
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        updateItem(id: item.id) { $0.content = trimmed }
        saveToDisk()
    }

    /// 更新单条：替换整个数组以触发 @Published
    private func updateItem(id: ClipboardItem.ID, _ transform: (inout ClipboardItem) -> Void) {
        guard let idx = items.firstIndex(where: { $0.id == id }) else { return }
        var updated = items[idx]
        transform(&updated)
        var newItems = items
        newItems[idx] = updated
        items = newItems
    }

    /// 钉住项置顶，其余按时间倒序（已对 items 整体赋值，会触发 @Published）
    private func sortPinnedFirst() {
        items = items.sorted { a, b in
            if a.isPinned != b.isPinned { return a.isPinned }
            return a.timestamp > b.timestamp
        }
    }

    /// 删除单条
    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
        saveToDisk()
    }

    /// 清空历史（全部）
    func clearAll() {
        items.removeAll()
        saveToDisk()
    }

    /// 清空未钉住的历史，已置顶项保留
    func clearUnpinned() {
        items.removeAll { !$0.isPinned }
        saveToDisk()
    }

    /// 将选中项写回系统剪贴板
    func copyToPasteboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        switch item.type {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let base64 = item.imageDataBase64, let data = Data(base64Encoded: base64), let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        }
        lastChangeCount = pasteboard.changeCount
    }

    // MARK: - 持久化

    private func loadFromDisk() {
        queue.async { [weak self] in
            guard let self else { return }
            guard FileManager.default.fileExists(atPath: self.storageURL.path),
                  let raw = try? Data(contentsOf: self.storageURL) else {
                DispatchQueue.main.async { [weak self] in self?.items = [] }
                return
            }
            let data: Data
            do {
                data = try ClipboardCrypto.shared.decrypt(raw)
            } catch {
                data = raw
            }
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let list = try? decoder.decode([ClipboardItem].self, from: data) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.items = list
                    self.sortPinnedFirst()
                    self.trimIfNeeded()
                }
            }
        }
    }

    private func saveToDisk() {
        let current = items
        queue.async { [weak self] in
            guard let self else { return }
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            guard let json = try? encoder.encode(current),
                  let encrypted = try? ClipboardCrypto.shared.encrypt(json) else { return }
            try? encrypted.write(to: self.storageURL)
        }
    }
}

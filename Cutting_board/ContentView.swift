//
//  ContentView.swift
//  Cutting_board
//
//  剪贴板历史面板
//

import SwiftUI
import AppKit

// MARK: - 设计系统
private enum Layout {
    static let paddingH: CGFloat = 20
    static let paddingHeaderV: CGFloat = 14
    static let paddingSearchV: CGFloat = 10
    static let cornerRadius: CGFloat = 12
    static let spring: Animation = .spring(response: 0.3, dampingFraction: 0.8)
}

struct ContentView: View {
    @ObservedObject private var store = ClipboardStore.shared
    @State private var selectedId: ClipboardItem.ID?
    @State private var searchText = ""
    @State private var remarkEditItem: ClipboardItem?
    @State private var remarkEditText: String = ""
    @State private var contentEditItem: ClipboardItem?
    @State private var contentEditText: String = ""
    @State private var showSettings = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var filteredItems: [ClipboardItem] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return store.items }
        return store.items.filter {
            $0.content.localizedStandardContains(q) || ($0.remark?.localizedStandardContains(q) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            searchBar
            Group {
                if store.items.isEmpty {
                    emptyView
                } else if filteredItems.isEmpty {
                    noSearchResultsView
                } else {
                    listView
                }
            }
            .id(store.items.isEmpty ? "empty" : (filteredItems.isEmpty ? "noResults" : "list"))
            .animation(reduceMotion ? nil : Layout.spring, value: store.items.isEmpty)
            .animation(reduceMotion ? nil : Layout.spring, value: filteredItems.isEmpty)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .frame(minWidth: 380, minHeight: 340, maxHeight: 560)
        .glassEffect(.regular, in: .rect(cornerRadius: Layout.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous)
                .strokeBorder(.primary.opacity(0.08), lineWidth: 1)
        )
        .onAppear {
            selectedId = filteredItems.first?.id
        }
        .onChange(of: searchText) { _, _ in
            if let id = selectedId, !filteredItems.contains(where: { $0.id == id }) {
                selectedId = filteredItems.first?.id
            }
        }
        .onKeyPress(.upArrow) {
            moveSelection(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveSelection(by: 1)
            return .handled
        }
        .onKeyPress(.return) {
            if let id = selectedId, let item = store.items.first(where: { $0.id == id }) {
                pasteItem(item)
                return .handled
            }
            return .ignored
        }
        .onKeyPress(.escape) {
            closePanel()
            return .handled
        }
        .sheet(item: $remarkEditItem) { item in
            remarkEditSheet(for: item)
                .presentationBackground(.thinMaterial)
        }
        .sheet(item: $contentEditItem) { item in
            contentEditSheet(for: item)
                .presentationBackground(.thinMaterial)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.on.clipboard")
                .font(.title2)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("剪贴板")
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
            if !store.items.isEmpty {
                Text("共 \(store.items.count) 条")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("共 \(store.items.count) 条记录")
            }
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.body)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("设置")
            if !store.items.isEmpty {
                Button("清空") {
                    store.clearUnpinned()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityLabel("清空")
                .accessibilityHint("清空未钉住的历史，已置顶项保留")
            }
        }
        .padding(.horizontal, Layout.paddingH)
        .padding(.vertical, Layout.paddingHeaderV)
        .background(.ultraThinMaterial.opacity(0.6))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("剪贴板")
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            TextField("搜索内容或备注", text: $searchText)
                .textFieldStyle(.plain)
                .accessibilityLabel("搜索")
                .accessibilityHint("按内容或备注过滤列表")
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清除搜索")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, Layout.paddingSearchV)
        .glassEffect(.regular, in: .rect(cornerRadius: Layout.cornerRadius))
        .padding(.horizontal, Layout.paddingH)
        .padding(.bottom, 12)
    }

    private var noSearchResultsView: some View {
        ContentUnavailableView("未找到匹配「\(searchText)”", systemImage: "magnifyingglass")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
    }

    private var emptyView: some View {
        ContentUnavailableView {
            Label("暂无历史", systemImage: "doc.on.clipboard")
        } description: {
            Text("复制文字或图片后会自动出现在这里")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("暂无历史，复制文字或图片后会自动出现在这里")
    }

    private var listView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(filteredItems) { item in
                        listRow(for: item)
                            .id(item.id)
                    }
                }
                .padding(.vertical, 4)
            }
            .scrollIndicators(.hidden)
            .onChange(of: selectedId) { _, newId in
                guard let id = newId else { return }
                withTransaction(Transaction(animation: nil)) { proxy.scrollTo(id, anchor: .center) }
            }
        }
        .onKeyPress(.delete) {
            guard let id = selectedId, let item = store.items.first(where: { $0.id == id }) else { return .ignored }
            store.remove(item)
            selectedId = filteredItems.first { $0.id != id }?.id ?? filteredItems.first?.id
            return .handled
        }
    }

    @ViewBuilder
    private func listRow(for item: ClipboardItem) -> some View {
        let selected = selectedId == item.id
        ClipboardRowView(
            item: item,
            isSelected: selected,
            onTogglePin: { store.togglePin(item) },
            onEditRemark: { openRemarkEdit(for: item) },
            onEditContent: item.type == .text ? { openContentEdit(for: item) } : nil
        )
        .equatable()
        .contentShape(Rectangle())
        .padding(.horizontal, Layout.paddingH)
        .padding(.vertical, 6)
        .onTapGesture(count: 1) { selectedId = item.id }
        .onTapGesture(count: 2) { pasteItem(item) }
        .accessibilityLabel(rowAccessibilityLabel(for: item))
        .accessibilityHint("双击粘贴到当前应用")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .contextMenu {
            Button("编辑备注") { openRemarkEdit(for: item) }
            if item.type == .text {
                Button("编辑内容") { openContentEdit(for: item) }
            }
            Divider()
            Button("删除", role: .destructive) {
                store.remove(item)
                if selectedId == item.id { selectedId = filteredItems.first?.id }
            }
        }
    }

    private func openRemarkEdit(for item: ClipboardItem) {
        remarkEditItem = item
        remarkEditText = item.remark ?? ""
    }

    private func openContentEdit(for item: ClipboardItem) {
        guard item.type == .text else { return }
        contentEditItem = item
        contentEditText = item.content
    }

    private func contentEditSheet(for item: ClipboardItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("编辑内容")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            TextEditor(text: $contentEditText)
                .font(.body)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: Layout.cornerRadius))
                .frame(minHeight: 120, maxHeight: 280)
                .accessibilityLabel("内容")
                .accessibilityHint("修改剪贴板文本内容")
            HStack {
                Spacer()
                Button("取消") {
                    contentEditItem = nil
                    contentEditText = ""
                }
                .keyboardShortcut(.escape)
                .accessibilityLabel("取消")
                Button("保存") {
                    store.updateContent(item, content: contentEditText)
                    contentEditItem = nil
                    contentEditText = ""
                }
                .keyboardShortcut(.defaultAction)
                .disabled(contentEditText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .accessibilityLabel("保存内容")
            }
        }
        .padding(Layout.paddingH)
        .frame(minWidth: 360, minHeight: 260)
    }

    private func remarkEditSheet(for item: ClipboardItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("编辑备注")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            TextField("备注（可用于搜索）", text: $remarkEditText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
                .background(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: Layout.cornerRadius))
                .lineLimit(2...6)
                .accessibilityLabel("备注")
                .accessibilityHint("输入备注便于搜索")
            HStack {
                Spacer()
                Button("取消") {
                    remarkEditItem = nil
                    remarkEditText = ""
                }
                .keyboardShortcut(.escape)
                .accessibilityLabel("取消")
                Button("保存") {
                    store.updateRemark(item, remark: remarkEditText)
                    remarkEditItem = nil
                    remarkEditText = ""
                }
                .keyboardShortcut(.defaultAction)
                .accessibilityLabel("保存备注")
            }
        }
        .padding(Layout.paddingH)
        .frame(minWidth: 280)
    }

    private func moveSelection(by delta: Int) {
        let list = filteredItems
        guard !list.isEmpty else { return }
        let idx: Int
        if let id = selectedId, let i = list.firstIndex(where: { $0.id == id }) {
            idx = max(0, min(list.count - 1, i + delta))
        } else {
            selectedId = list.first?.id
            return
        }
        selectedId = list[idx].id
    }

    private func pasteItem(_ item: ClipboardItem) {
        store.copyToPasteboard(item)
        closePanel()
    }

    private func closePanel() {
        NotificationCenter.default.post(name: .closeClipboardPanel, object: nil)
    }

    private func rowAccessibilityLabel(for item: ClipboardItem) -> String {
        let typeStr = item.type == .text ? "文本" : "图片"
        var parts = [typeStr, item.timeAgo]
        if item.isPinned { parts.append("已钉住") }
        if let r = item.remark, !r.isEmpty { parts.append("备注：\(r)") }
        return parts.joined(separator: "，")
    }
}

// MARK: - 键盘选中阴影
private struct KeyboardSelectionShadow: ViewModifier {
    let isSelected: Bool
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(isSelected ? 0.24 : 0), radius: isSelected ? 12 : 0, x: 0, y: isSelected ? 4 : 0)
            .animation(reduceMotion ? nil : Layout.spring, value: isSelected)
    }
}

// MARK: - 单行

struct ClipboardRowView: View, Equatable {
    let item: ClipboardItem
    var isSelected: Bool = false
    var onTogglePin: (() -> Void)?
    var onEditRemark: (() -> Void)?
    var onEditContent: (() -> Void)?

    static func == (lhs: ClipboardRowView, rhs: ClipboardRowView) -> Bool {
        lhs.item.id == rhs.item.id
            && lhs.isSelected == rhs.isSelected
            && lhs.item.remark == rhs.item.remark
            && lhs.item.isPinned == rhs.item.isPinned
            && lhs.item.content == rhs.item.content
    }

    @State private var isHovered = false
    @State private var cachedThumbnail: NSImage?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.colorScheme) private var colorScheme

    private let thumbnailSize: CGFloat = 44

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leadingView
            VStack(alignment: .leading, spacing: 4) {
                contentPreview
                remarkLine
                Text(item.timeAgo)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                if onEditContent != nil {
                    Button { onEditContent?() } label: {
                        Image(systemName: "pencil")
                            .font(.body)
                            .foregroundStyle(Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("编辑内容")
                    .accessibilityHint("修改剪贴板文本内容")
                }
                Button { onEditRemark?() } label: {
                    Image(systemName: hasRemarkForItem ? "note.text" : "note.text.badge.plus")
                        .font(.body)
                        .foregroundStyle(hasRemarkForItem ? Color.orange.opacity(0.9) : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(hasRemarkForItem ? "编辑备注" : "添加备注")
                .accessibilityHint("为这条记录添加或修改备注")
                Button {
                    onTogglePin?()
                } label: {
                    Image(systemName: item.isPinned ? "pin.fill" : "pin")
                        .font(.body)
                        .foregroundStyle(item.isPinned ? Color.orange : Color.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isPinned ? "取消钉住" : "钉住")
                .accessibilityHint("钉住后置顶且不会被自动清理")
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(rowBackground)
        .clipShape(.rect(cornerRadius: Layout.cornerRadius))
        .compositingGroup()
        .modifier(KeyboardSelectionShadow(isSelected: isSelected, reduceMotion: reduceMotion))
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
        .animation(reduceMotion ? nil : Layout.spring, value: isHovered)
        .task(id: item.id) {
            guard item.type == .image else { return }
            cachedThumbnail = thumbnailImage
        }
    }

    private var hasRemarkForItem: Bool {
        !(item.remark ?? "").isEmpty
    }

    /// 备注行：有备注显示内容，无备注显示占位「无备注」
    private var remarkLine: some View {
        HStack(spacing: 4) {
            Image(systemName: "note.text")
                .font(.caption2)
                .foregroundStyle(hasRemarkForItem ? Color.orange.opacity(0.8) : Color.gray.opacity(0.65))
            Text(hasRemarkForItem ? (item.remark ?? "") : "无备注")
                .font(.caption)
                .foregroundStyle(hasRemarkForItem ? Color.secondary : Color.gray.opacity(0.65))
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if isSelected {
            Color.clear
                .glassEffect(.regular.tint(.primary.opacity(0.12)).interactive(), in: .rect(cornerRadius: Layout.cornerRadius))
        } else if isHovered {
            Color.clear
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: Layout.cornerRadius))
        } else {
            Color.clear
        }
    }

    private var leadingView: some View {
        Group {
            if item.type == .image, let img = cachedThumbnail {
                Image(nsImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: thumbnailSize, height: thumbnailSize)
                    .clipped()
                    .clipShape(.rect(cornerRadius: Layout.cornerRadius))
            } else {
                typeIcon
            }
        }
        .frame(width: thumbnailSize, height: thumbnailSize)
    }

    private var contentPreview: some View {
        Group {
            if item.type == .text, let attr = markdownPreview {
                Text(attr).lineLimit(2)
            } else {
                Text(item.previewText).lineLimit(2).font(.system(.body, design: .default))
            }
        }
    }

    private var thumbnailImage: NSImage? {
        guard let base64 = item.imageDataBase64,
              let data = Data(base64Encoded: base64) else { return nil }
        let img = NSImage(data: data)
        return img?.resizedForThumbnail(maxSize: thumbnailSize)
    }

    /// 对预览长度文本尝试 Markdown 解析，失败则 nil
    private var markdownPreview: AttributedString? {
        let raw = item.previewText
        guard !raw.isEmpty else { return nil }
        return try? AttributedString(markdown: raw)
    }

    private var typeIcon: some View {
        Group {
            switch item.type {
            case .text: Image(systemName: "doc.text").foregroundStyle(.blue)
            case .image: Image(systemName: "photo").foregroundStyle(.green)
            }
        }
        .font(.title2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityHidden(true)
    }
}

// MARK: - NSImage 缩略图

extension NSImage {
    func resizedForThumbnail(maxSize: CGFloat) -> NSImage? {
        let w = size.width
        let h = size.height
        guard w > 0, h > 0 else { return nil }
        let scale = min(maxSize / w, maxSize / h, 1)
        guard scale < 1 else { return self }
        let newW = w * scale
        let newH = h * scale
        let newImg = NSImage(size: NSSize(width: newW, height: newH))
        newImg.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(x: 0, y: 0, width: newW, height: newH),
             from: NSRect(x: 0, y: 0, width: w, height: h),
             operation: .copy,
             fraction: 1)
        newImg.unlockFocus()
        return newImg
    }
}

#Preview {
    ContentView()
        .frame(width: 380, height: 400)
}

//
//  Cutting_boardApp.swift
//  Cutting_board
//
//  Created by WJIAEN on 2026/2/2.
//

import AppKit
import SwiftUI

@main
struct Cutting_boardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("剪贴板", systemImage: "doc.on.clipboard") {
            Button("打开/关闭剪贴板 (⌘P)") {
                AppDelegate.shared?.toggleClipboardPanel()
            }
            .keyboardShortcut("p", modifiers: .command)

            Divider()

            Button("退出") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: .command)
        }
        .menuBarExtraStyle(.menu)
    }
}

// MARK: - 后台运行、自建面板窗口、全局快捷键

final class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?

    /// 剪贴板面板窗口（由 AppDelegate 在启动时用 AppKit 创建，不依赖 SwiftUI WindowGroup）
    private var panelWindow: NSWindow?

    override init() {
        super.init()
        AppDelegate.shared = self
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        createPanelWindowIfNeeded()
        HotKeyService.register()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowClipboardPanel),
            name: .showClipboardPanel,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCloseClipboardPanel),
            name: .closeClipboardPanel,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleToggleClipboardPanel),
            name: .toggleClipboardPanel,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotKeyService.unregister()
        NotificationCenter.default.removeObserver(self)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// 创建剪贴板面板窗口（LSUIElement 下 SwiftUI 不会自动创建 WindowGroup 窗口，必须自建）
    private func createPanelWindowIfNeeded() {
        guard panelWindow == nil else { return }

        let content = ContentView()
        let hosting = NSHostingView(rootView: content)
        hosting.frame = NSRect(x: 0, y: 0, width: 380, height: 420)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 380, height: 420),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
//        window.title = "剪贴板"
        window.contentView = hosting
        window.isReleasedWhenClosed = false
        window.center()

        panelWindow = window
    }

    /// 菜单/快捷键/通知 调起面板
    func showClipboardPanel() {
        createPanelWindowIfNeeded()
        guard let w = panelWindow else { return }
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak w] in
            guard let window = w, let contentView = window.contentView else { return }
            if let tableView = Self.findFirstTableView(in: contentView) {
                window.makeFirstResponder(tableView)
            }
        }
    }

    /// 在视图层级中递归查找第一个 NSTableView（List 的底层视图），用于把键盘焦点交给列表
    private static func findFirstTableView(in view: NSView) -> NSTableView? {
        if let tableView = view as? NSTableView { return tableView }
        for subview in view.subviews {
            if let found = findFirstTableView(in: subview) { return found }
        }
        return nil
    }

    @objc private func handleShowClipboardPanel() {
        showClipboardPanel()
    }

    @objc private func handleCloseClipboardPanel() {
        panelWindow?.orderOut(nil)
    }

    @objc private func handleToggleClipboardPanel() {
        toggleClipboardPanel()
    }

    /// 切换面板显示：已显示则关闭，未显示则打开
    func toggleClipboardPanel() {
        if panelWindow?.isVisible == true {
            panelWindow?.orderOut(nil)
        } else {
            showClipboardPanel()
        }
    }
}

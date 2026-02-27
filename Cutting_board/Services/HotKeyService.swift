//
//  HotKeyService.swift
//  Cutting_board
//
//  全局快捷键 Command+P 调起剪贴板面板（Carbon API，有无焦点均可、无需辅助功能）
//

import AppKit
import Carbon
import Foundation

extension Notification.Name {
    static let showClipboardPanel = Notification.Name("ShowClipboardPanel")
    static let closeClipboardPanel = Notification.Name("CloseClipboardPanel")
    static let toggleClipboardPanel = Notification.Name("ToggleClipboardPanel")
}

/// 字母 P 的 keyCode
private let keyCodeP: UInt32 = 35 // kVK_ANSI_P

/// Carbon 热键回调（须为 C 可调用，不捕获上下文）
private func hotKeyHandler(_: EventHandlerCallRef?, _: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus {
    DispatchQueue.main.async {
        NotificationCenter.default.post(name: .toggleClipboardPanel, object: nil)
    }
    return noErr
}

/// 使用 Carbon 注册全局热键，任意应用聚焦时都能触发，无需辅助功能权限
enum HotKeyService {
    private static var hotKeyRef: EventHotKeyRef?
    private static var eventHandler: EventHandlerRef?
    private static let hotKeySignature: OSType = 0x44494E47 // "DING" 四字符码
    private static let hotKeyID = EventHotKeyID(signature: 0x44494E47, id: 1)

    static func register() {
        unregister()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        var handler: EventHandlerRef?
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            hotKeyHandler,
            1,
            &eventType,
            nil,
            &handler
        )
        eventHandler = handler
        guard status == noErr else { return }

        var ref: EventHotKeyRef?
        let regStatus = RegisterEventHotKey(
            keyCodeP,
            UInt32(cmdKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &ref
        )
        hotKeyRef = ref
        if regStatus != noErr {
            hotKeyRef = nil
            if let h = eventHandler {
                RemoveEventHandler(h)
                eventHandler = nil
            }
        }
    }

    static func unregister() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        if let h = eventHandler {
            RemoveEventHandler(h)
            eventHandler = nil
        }
    }
}

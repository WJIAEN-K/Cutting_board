//
//  ClipboardItem.swift
//  Cutting_board
//
//  剪贴板历史条目模型
//

import Foundation

/// 剪贴板内容类型
enum ClipboardContentType: String, Codable {
    case text
    case image
}

/// 单条剪贴板历史记录
struct ClipboardItem: Identifiable, Codable, Equatable {
    var id: UUID
    var content: String
    var type: ClipboardContentType
    var timestamp: Date
    /// 图片数据（仅 type == .image 时使用，存为 Base64）
    var imageDataBase64: String?
    /// 是否钉住：钉住后置顶且不会被 trim 清理
    var isPinned: Bool
    /// 用户备注，可用于搜索
    var remark: String?

    init(
        id: UUID = UUID(),
        content: String,
        type: ClipboardContentType,
        timestamp: Date = Date(),
        imageDataBase64: String? = nil,
        isPinned: Bool = false,
        remark: String? = nil
    ) {
        self.id = id
        self.content = content
        self.type = type
        self.timestamp = timestamp
        self.imageDataBase64 = imageDataBase64
        self.isPinned = isPinned
        self.remark = remark
    }

    enum CodingKeys: String, CodingKey {
        case id, content, type, timestamp, imageDataBase64, isPinned, remark
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        content = try c.decode(String.self, forKey: .content)
        type = try c.decode(ClipboardContentType.self, forKey: .type)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
        imageDataBase64 = try c.decodeIfPresent(String.self, forKey: .imageDataBase64)
        isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        remark = try c.decodeIfPresent(String.self, forKey: .remark)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(content, forKey: .content)
        try c.encode(type, forKey: .type)
        try c.encode(timestamp, forKey: .timestamp)
        try c.encodeIfPresent(imageDataBase64, forKey: .imageDataBase64)
        try c.encode(isPinned, forKey: .isPinned)
        try c.encodeIfPresent(remark, forKey: .remark)
    }

    /// 用于列表显示的预览文本（截断）
    var previewText: String {
        let maxLen = 80
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "(空)" }
        if trimmed.count <= maxLen { return trimmed }
        return String(trimmed.prefix(maxLen)) + "…"
    }

    /// 时间描述
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

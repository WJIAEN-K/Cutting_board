//
//  ClipboardCrypto.swift
//  Cutting_board
//
//  剪贴板历史文件加密：Keychain 存密钥 + AES-GCM 加密，防止其他软件读取
//

import CryptoKit
import Foundation
import Security

private let keychainService = "WJIAEN.Cutting-board.clipboard"
private let keychainAccount = "history-key"
private let magicHeader = "CB1".data(using: .utf8)! // 加密文件头，用于区分明文历史

struct ClipboardCrypto {
    static let shared = ClipboardCrypto()

    private init() {}

    private var key: SymmetricKey {
        if let data = loadKeyFromKeychain() {
            return SymmetricKey(data: data)
        }
        var keyData = Data(count: 32)
        _ = keyData.withUnsafeMutableBytes { SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!) }
        saveKeyToKeychain(keyData)
        return SymmetricKey(data: keyData)
    }

    /// 加密后写入的格式：magicHeader(3) + sealedBox.combined
    func encrypt(_ data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else { throw CocoaError(.coderInvalidValue) }
        return magicHeader + combined
    }

    /// 若为加密格式则解密并返回明文，否则返回原 data（兼容旧明文）
    func decrypt(_ data: Data) throws -> Data {
        guard data.count > magicHeader.count, data.prefix(magicHeader.count) == magicHeader else {
            return data
        }
        let combined = data.dropFirst(magicHeader.count)
        let sealedBox = try AES.GCM.SealedBox(combined: combined)
        return try AES.GCM.open(sealedBox, using: key)
    }

    private func loadKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data, data.count == 32 else { return nil }
        return data
    }

    private func saveKeyToKeychain(_ keyData: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}

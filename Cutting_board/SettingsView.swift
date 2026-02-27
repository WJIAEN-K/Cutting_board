//
//  SettingsView.swift
//  Cutting_board
//
//  设置页：忽略应用程序等
//

import SwiftUI
import AppKit

struct SettingsView: View {
    @ObservedObject private var ignoredStore = IgnoredAppsStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("设置")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("完成") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ignoredAppsSection
                }
                .padding(20)
            }
        }
        .frame(minWidth: 420, minHeight: 320)
        .glassEffect(.regular, in: .rect(cornerRadius: 12))
    }

    private var ignoredAppsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("忽略应用程序")
                .font(.headline)
            Text("不要保存从以下应用程序复制的内容。")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                ForEach(ignoredStore.bundleIDs, id: \.self) { bundleID in
                    HStack(spacing: 12) {
                        if let img = AppInfoHelper.icon(for: bundleID) {
                            Image(nsImage: img)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        Text(AppInfoHelper.name(for: bundleID))
                            .font(.body)
                        Spacer()
                        Button {
                            ignoredStore.remove(bundleID: bundleID)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .glassEffect(.regular, in: .rect(cornerRadius: 8))

                    if bundleID != ignoredStore.bundleIDs.last {
                        Spacer().frame(height: 8)
                    }
                }
            }

            Button {
                if let id = AppInfoHelper.pickApplicationBundleID() {
                    ignoredStore.add(bundleID: id)
                }
            } label: {
                Text("+ 添加应用")
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    SettingsView()
        .frame(width: 420, height: 400)
}

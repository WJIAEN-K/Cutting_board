# Cutting_board v1.0.0 - 首次公开发布

🎉 我们很高兴地宣布 Cutting_board 1.0.0 正式发布！

## 🌟 亮点功能

### 全局快捷键，零权限要求
- 使用 Carbon API 实现 `⌘P` 全局唤起面板
- 无需辅助功能权限即可使用所有核心功能
- 在任何应用聚焦状态下都能快速访问

### 实时监控，智能管理
- 每 0.5 秒自动轮询系统剪贴板
- 支持文本和图片内容捕获
- 智能去重，避免重复记录
- 最多保存 200 条历史记录

### 数据安全，隐私优先
- AES-GCM 加密算法保护历史数据
- 密钥存储于 macOS Keychain，永不落盘
- 完全本地运行，无网络请求
- 无追踪、无统计、无广告

### 现代界面，流畅体验
- SwiftUI + AppKit 混合开发
- Liquid Glass 玻璃材质视觉效果
- 完整的无障碍支持（VoiceOver）
- 键盘导航优化（上下箭头、回车、Esc）

## 📦 安装方式

### 方法一：下载预编译版本
1. 从下方 Assets 下载 `ding-mac.zip`
2. 解压后将 `ding.app` 拖入 `/Applications` 文件夹
3. 在菜单栏点击图标或按 `⌘P` 使用

### 方法二：从源码构建
```bash
git clone https://github.com/WJIAEN/Cutting_board.git
cd Cutting_board
./build-and-package.sh
```

## 🚀 快速开始

### 基本操作
| 快捷键 | 功能 |
|--------|------|
| `⌘P` | 打开/关闭剪贴板面板 |
| `↑` / `↓` | 上下移动选中项 |
| `Enter` | 粘贴选中项 |
| `Delete` | 删除选中项 |
| `Esc` | 关闭面板 |
| `⌘Q` | 退出应用 |

### 高级功能
- **添加备注**: 右键点击条目 → "编辑备注"
- **置顶条目**: 点击图钉图标，置顶后不会被清理
- **忽略应用**: 设置页添加不想记录的应用
- **清空历史**: 点击"清空"按钮，保留已置顶项

## 🔧 技术规格

### 系统要求
- **macOS**: 26.1 (Sequoia) 或更高版本
- **Xcode**: 16.0+
- **Swift**: 5.9+

### 核心技术栈
- SwiftUI + AppKit
- Carbon API（全局热键）
- CryptoKit（AES-GCM 加密）
- Security Framework（Keychain）
- Combine（响应式数据流）

## 📝 已知问题

1. **大尺寸图片**: 可能导致历史文件体积较大，建议在后续版本中优化缩略图策略
2. **快捷键冲突**: 某些系统快捷键可能与 `⌘P` 冲突，可在系统设置中调整
3. **首次启动**: 可能需要短暂时间初始化 Keychain 密钥

## 🐛 Bug 反馈

如遇到问题，请提交 Issue：https://github.com/WJIAEN/Cutting_board/issues

## 🙏 致谢

感谢所有参与测试和提供反馈的用户！

## 📄 许可证

MIT License - 详见 LICENSE 文件

---

**完整更新日志**: [CHANGELOG.md](CHANGELOG.md)  
**使用文档**: [README.md](README.md)  
**贡献指南**: [CONTRIBUTING.md](CONTRIBUTING.md)

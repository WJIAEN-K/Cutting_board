# 更新日志 (CHANGELOG)

本文档记录 Cutting_board 项目的所有重要变更。格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，版本号遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [未发布]

### Added
- 初始开源发布
- 完整的 Wiki 文档（中文）
- README、CONTRIBUTING、CHANGELOG 等开源文件
- MIT 许可证

---

## [1.0.0] - 2026-02-15

### 新增功能
- **全局快捷键** - 使用 Carbon API 实现 `⌘P` 全局唤起面板，无需辅助功能权限
- **剪贴板监控** - 每 0.5 秒轮询系统剪贴板，自动记录文本和图片
- **历史管理**
  - 支持最多 200 条历史记录
  - 置顶（钉住）功能，置顶项不会被清理
  - 备注功能，可为每条记录添加自定义备注
  - 搜索功能，支持按内容或备注过滤
  - 清空未置顶项，快速清理历史
- **数据安全**
  - AES-GCM 加密算法加密历史文件
  - 密钥存储于 macOS Keychain
  - 兼容明文旧版本，支持无缝升级
- **应用忽略策略**
  - 支持添加/移除忽略的应用程序
  - 从特定应用复制的内容不会被记录
  - 图形化界面管理忽略列表
- **用户界面**
  - SwiftUI + AppKit 混合开发
  - 玻璃材质视觉效果（Liquid Glass）
  - 完整的无障碍支持（VoiceOver）
  - 键盘导航：上下箭头选择、回车粘贴、Esc 关闭
  - 右键菜单：编辑备注、删除条目
  - 双击快速粘贴
- **性能优化**
  - LazyVStack 延迟渲染长列表
  - 图片缩略图按需生成并缓存
  - 异步持久化，不阻塞主线程
  - 支持减少动画选项（无障碍模式）

### 技术特性
- **架构设计**
  - 模型 - 服务 - 视图分层架构
  - 单例模式管理服务实例
  - 通知中心解耦组件通信
  - Combine 框架响应式数据流
- **加密安全**
  - CryptoKit AES-GCM 对称加密
  - Security Framework Keychain 密钥管理
  - 魔数头标识加密格式，兼容明文
- **系统集成**
  - NSPasteboard 实时读取剪贴板
  - Carbon HotKey 全局热键注册
  - NSWorkspace 获取应用信息
  - UserDefaults 存储用户配置

### 已知问题
- 首次启动时需要授予辅助功能权限（可选，仅用于增强体验）
- 大尺寸图片可能导致历史文件体积较大
- 某些系统快捷键可能与 `⌘P` 冲突

---

## 版本说明

### 版本号规则
- **MAJOR.MINOR.PATCH** (例如：1.0.0)
- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的 Bug 修复

### 发布周期
- **Major 版本**: 每 3-6 个月（重大功能更新）
- **Minor 版本**: 每 2-4 周（功能改进和优化）
- **Patch 版本**: 随时发布（Bug 修复和安全补丁）

---

## 贡献者

感谢所有为这个项目做出贡献的开发者！

完整贡献者名单请参阅：[GitHub Contributors](https://github.com/WJIAEN/Cutting_board/graphs/contributors)

---

**注意**：此 CHANGELOG 从 v1.0.0 开始记录。早期内部开发版本未在此列出。

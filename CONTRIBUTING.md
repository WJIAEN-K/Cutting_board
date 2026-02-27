# 贡献指南

欢迎参与 Cutting_board 项目的开发！本文档将帮助你了解如何贡献代码。

## 📋 目录

- [行为准则](#行为准则)
- [我能贡献什么](#我能贡献什么)
- [开发环境配置](#开发环境配置)
- [代码规范](#代码规范)
- [提交流程](#提交流程)
- [Code Review](#code-review)
- [发布流程](#发布流程)

## 行为准则

本项目采用 [Contributor Covenant](https://www.contributor-covenant.org/) 行为准则。请保持友好、尊重的交流氛围，共同维护健康的开源社区。

## 我能贡献什么

### 1. 报告问题
发现 Bug 或有功能建议？请创建 [Issue](https://github.com/WJIAEN/Cutting_board/issues)：
- **Bug 报告**：包含复现步骤、预期行为、实际行为、系统版本
- **功能建议**：描述使用场景、期望功能、可能的实现方案

### 2. 提交代码
- 修复已知 Bug
- 实现新功能（请先在 Issue 中讨论）
- 改进文档
- 优化性能
- 添加测试用例

### 3. 其他贡献方式
- 翻译文档
- 设计 UI/UX
- 分享使用经验
- 帮助回答其他用户的问题

## 开发环境配置

### 系统要求
- macOS 26.1 (Sequoia) 或更高版本
- Xcode 16.0+
- Swift 5.9+

### 搭建步骤

```bash
# 1. Fork 项目
# 在 GitHub 上点击 Fork 按钮

# 2. 克隆仓库
git clone https://github.com/YOUR_USERNAME/Cutting_board.git
cd Cutting_board

# 3. 打开 Xcode 项目
open Cutting_board.xcodeproj

# 4. 运行项目
# 在 Xcode 中选择 Cutting_board scheme，按 ⌘R 运行
```

### 构建与测试

```bash
# Debug 构建
xcodebuild -scheme Cutting_board -configuration Debug build

# Release 构建
xcodebuild -scheme Cutting_board -configuration Release build

# 打包应用
./build-and-package.sh
```

## 代码规范

### Swift 编码风格

#### 命名约定
```swift
// 类型使用 PascalCase
class ClipboardStore { }
enum ContentType { }

// 变量和函数使用 camelCase
var maxItems: Int = 200
func togglePin(_ item: ClipboardItem) { }

// 常量使用 uppercase
let MAX_HISTORY_COUNT = 200

// 私有属性添加 private 标记
private var timer: Timer?
```

#### 代码组织
```swift
// MARK: - 生命周期
init() { }

// MARK: - 公开方法
func publicMethod() { }

// MARK: - 私有方法
private func privateMethod() { }

// MARK: - 计算属性
private var computedProperty: Type { }
```

#### 注释规范
```swift
/// 函数的文档注释
/// - Parameters:
///   - item: 剪贴板条目
///   - remark: 备注文本
func updateRemark(_ item: ClipboardItem, remark: String?) {
    // 单行注释说明复杂逻辑
    let trimmed = remark?.trimmingCharacters(in: .whitespacesAndNewlines)
}
```

#### 格式化工具
推荐使用 [SwiftFormat](https://github.com/nicklockwood/SwiftFormat)：

```bash
# 安装
brew install swiftformat

# 格式化代码
swiftformat .
```

### Git 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/)：

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type 类型
- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整（不影响功能）
- `refactor`: 重构（既非新功能也非 Bug 修复）
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建过程或辅助工具变动

#### 示例
```bash
# 新功能
git commit -m "feat(ui): 添加搜索历史功能"

# Bug 修复
git commit -m "fix(crypto): 修复 Keychain 密钥读取失败的问题"

# 文档更新
git commit -m "docs(readme): 更新安装说明"

# 详细提交信息
git commit -m "perf(store): 优化剪贴板监控性能

- 将轮询间隔从 1s 降低到 0.5s
- 使用 DispatchQueue 异步处理持久化
- 减少主线程阻塞

Closes #42"
```

## 提交流程

### 1. 创建分支
```bash
# 基于 main 分支创建特性分支
git checkout -b feature/your-feature-name
# 或修复分支
git checkout -b fix/issue-42
```

### 2. 开发与提交
```bash
# 开发完成后提交
git add .
git commit -m "feat: add your feature description"
```

### 3. 同步上游
```bash
# 添加 upstream remote
git remote add upstream https://github.com/WJIAEN/Cutting_board.git

# 同步最新代码
git fetch upstream
git rebase upstream/main
```

### 4. 推送分支
```bash
git push origin feature/your-feature-name
```

### 5. 创建 Pull Request

在 GitHub 上：
1. 点击 **Compare & pull request**
2. 填写 PR 描述：
   - **标题**：简洁描述变更
   - **描述**：详细说明变更内容、动机、影响范围
   - **关联 Issue**：`Closes #123`
   - **截图**：UI 变更需提供前后对比
3. 选择 Reviewer
4. 提交 PR

### 6. CI 检查
PR 会自动运行以下检查：
- ✅ 构建是否成功
- ✅ 代码格式是否规范
- ✅ 静态分析是否有警告

### 7. Code Review
维护者会进行代码审查：
- 可能需要根据反馈进行修改
- 讨论实现方案的合理性
- 确保代码质量

### 8. 合并
审核通过后：
- PR 会被 squash merge 到 main 分支
- 特性分支会被删除
- 你可以在 Release Notes 中看到自己的贡献

## Code Review

### Review 标准

#### 代码质量
- [ ] 代码是否清晰易懂
- [ ] 是否有不必要的复杂性
- [ ] 是否遵循 Swift 最佳实践
- [ ] 错误处理是否完善

#### 功能正确性
- [ ] 是否实现了预期功能
- [ ] 边界条件是否考虑周全
- [ ] 是否有潜在的 Bug
- [ ] 性能影响是否可接受

#### 测试覆盖
- [ ] 是否添加了必要的测试
- [ ] 现有测试是否通过
- [ ] 边缘情况是否有测试覆盖

#### 文档完整性
- [ ] 公开 API 是否有文档注释
- [ ] 复杂逻辑是否有说明注释
- [ ] README 是否需要更新

### Review 礼仪
- 对事不对人，保持专业
- 提出建设性意见，而非批评
- 感谢 Reviewer 的时间和建议
- 积极回应反馈，及时修改

## 发布流程

### 版本号规则
遵循 [Semantic Versioning](https://semver.org/)：
- `MAJOR.MINOR.PATCH` (例如：1.2.3)
- **MAJOR**: 不兼容的 API 变更
- **MINOR**: 向后兼容的功能新增
- **PATCH**: 向后兼容的 Bug 修复

### 发布步骤（维护者）

1. 更新版本号（Xcode 项目设置）
2. 更新 CHANGELOG.md
3. 打 Tag：
   ```bash
   git tag -a v1.2.3 -m "Release version 1.2.3"
   git push origin v1.2.3
   ```
4. 运行打包脚本：
   ```bash
   ./build-and-package.sh
   ```
5. 在 GitHub Releases 页面创建新版本
6. 上传 `ding-mac.zip` 和 dSYM 文件

## 🎯 常见贡献场景

### 场景一：修复 Bug

```bash
# 1. 在 Issue 中确认 Bug
# 2. 创建修复分支
git checkout -b fix/issue-42

# 3. 编写修复代码
# 4. 添加测试用例（如适用）
# 5. 提交
git commit -m "fix(crypto): 修复 Keychain 密钥丢失导致历史无法加载的问题

当 Keychain 中的密钥被意外删除时，应用无法解密历史文件。
此修复会在检测到密钥丢失时自动生成新密钥，并保留旧文件作为备份。

Closes #42"

# 6. 推送并创建 PR
```

### 场景二：实现新功能

```bash
# 1. 在 Issue 中讨论功能必要性
# 2. 创建特性分支
git checkout -b feature/export-history

# 3. 实现功能
# 4. 提交（可多次提交）
git commit -m "feat(export): 添加导出历史记录为 JSON 的功能"

# 5. 更新文档
git commit -m "docs(readme): 添加导出功能使用说明"

# 6. 推送并创建 PR
```

### 场景三：改进文档

```bash
# 1. 创建分支
git checkout -b docs/update-readme

# 2. 修改文档
# 3. 提交
git commit -m "docs(readme): 完善快速开始指南

- 添加详细的安装步骤
- 补充常见问题解答
- 优化排版和可读性"

# 4. 推送并创建 PR
```

## 📚 学习资源

- [Swift 官方文档](https://docs.swift.org/swift-book/)
- [SwiftUI Tutorial](https://developer.apple.com/tutorials/swiftui)
- [AppKit Documentation](https://developer.apple.com/documentation/appkit)
- [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)

## ❓ 常见问题

### Q: 我的 PR 多久会被审核？
A: 通常在 1-3 个工作日内会有回复。如果超过一周未回复，可以 @mention 维护者。

### Q: 我可以一次提交多个功能吗？
A: 不建议。每个 PR 应该只关注一个功能或修复，便于审核和回滚。

### Q: 我的代码风格不符合规范怎么办？
A: 使用 SwiftFormat 自动格式化，或在 PR 中标注需要帮助，我们会协助调整。

### Q: 我没有 macOS 开发经验，能贡献吗？
A: 当然可以！文档改进、Bug 报告、功能建议都是宝贵的贡献。

## 🙏 致谢

感谢所有为这个项目做出贡献的开发者！

---

**第一次贡献？** 可以从标注为 [`good first issue`](https://github.com/WJIAEN/Cutting_board/labels/good%20first%20issue) 的 Issue 开始！

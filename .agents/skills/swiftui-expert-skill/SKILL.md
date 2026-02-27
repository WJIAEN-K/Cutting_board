---
name: swiftui-expert-skill
description: 遵循状态管理、视图组合、性能优化、现代API、Swift并发以及iOS 26+ Liquid Glass适配的最佳实践，编写、审核或改进SwiftUI代码。适用于构建新的SwiftUI功能、重构现有视图、审核代码质量或采用现代SwiftUI模式的场景。
tags: swiftui-development, state-management, modern-apis, performance-optimization,
  liquid-glass
tags_cn: SwiftUI开发, 状态管理, 现代API使用, 性能优化, Liquid Glass适配
---

# SwiftUI 专家技能指南

## 概述
使用本技能可按照正确的状态管理、现代API使用、Swift并发最佳实践、最优视图组合以及iOS 26+ Liquid Glass样式规范，构建、审核或改进SwiftUI功能。优先使用原生API、Apple设计指南和注重性能的模式。本技能聚焦于事实与最佳实践，不强制特定架构模式。

## 工作流决策树

### 1) 审核现有SwiftUI代码
- 对照选择指南检查属性包装器的使用（参见`references/state-management.md`）
- 验证现代API的使用情况（参见`references/modern-apis.md`）
- 验证视图组合是否遵循提取规则（参见`references/view-structure.md`）
- 检查是否应用了性能优化模式（参见`references/performance-patterns.md`）
- 验证列表模式是否使用稳定标识（参见`references/list-patterns.md`）
- 检查动画模式的正确性（参见`references/animation-basics.md`、`references/animation-transitions.md`）
- 检查Liquid Glass的使用是否正确且一致（参见`references/liquid-glass.md`）
- 验证iOS 26+特性的可用性处理是否包含合理的降级方案

### 2) 改进现有SwiftUI代码
- 审核状态管理，确保选择正确的包装器（优先使用`@Observable`而非`ObservableObject`）
- 使用现代等效API替代已废弃的API（参见`references/modern-apis.md`）
- 将复杂视图提取为独立的子视图（参见`references/view-structure.md`）
- 重构热点路径以减少冗余状态更新（参见`references/performance-patterns.md`）
- 确保ForEach使用稳定标识（参见`references/list-patterns.md`）
- 优化动画模式（使用value参数、正确的过渡效果，参见`references/animation-basics.md`、`references/animation-transitions.md`）
- 当检测到使用`UIImage(data:)`时，建议采用图像降采样作为可选优化方案（参见`references/image-optimization.md`）
- 仅在用户明确要求时才适配Liquid Glass

### 3) 实现新的SwiftUI功能
- 先设计数据流：区分自有状态与注入状态（参见`references/state-management.md`）
- 使用现代API（避免已废弃的修饰符或模式，参见`references/modern-apis.md`）
- 对共享状态使用`@Observable`（若未使用默认actor隔离，则添加`@MainActor`标记）
- 构建视图结构以实现最优差异对比（尽早提取子视图，保持视图轻量化，参见`references/view-structure.md`）
- 将业务逻辑分离到可测试的模型中（参见`references/layout-best-practices.md`）
- 使用正确的动画模式（隐式/显式动画、过渡效果，参见`references/animation-basics.md`、`references/animation-transitions.md`、`references/animation-advanced.md`）
- 在布局/外观修饰符之后应用玻璃效果（参见`references/liquid-glass.md`）
- 使用`#available`包裹iOS 26+特性并提供降级方案

## 核心准则

### 状态管理
- **新代码中始终优先使用`@Observable`而非`ObservableObject`**
- **为`@Observable`类标记`@MainActor`**，除非使用默认actor隔离
- **始终将`@State`和`@StateObject`标记为`private`**（明确依赖关系）
- **绝不要将传入的值声明为`@State`或`@StateObject`**（它们仅接受初始值）
- 为`@Observable`类搭配使用`@State`（而非`@StateObject`）
- 仅当子视图需要**修改**父视图状态时使用`@Binding`
- 对于需要绑定的注入式`@Observable`对象，使用`@Bindable`
- 只读值使用`let`；响应式读取使用`var` + `.onChange()`
- 遗留方案：自有`ObservableObject`使用`@StateObject`；注入式`ObservableObject`使用`@ObservedObject`
- 嵌套`ObservableObject`无法正常工作（直接传递嵌套对象即可）；`@Observable`可完美处理嵌套场景

### 现代API
- 使用`foregroundStyle()`替代`foregroundColor()`
- 使用`clipShape(.rect(cornerRadius:))`替代`cornerRadius()`
- 使用`Tab` API替代`tabItem()`
- 使用`Button`替代`onTapGesture()`（除非需要获取点击位置或次数）
- 使用`NavigationStack`替代`NavigationView`
- 使用`navigationDestination(for:)`实现类型安全的导航
- 使用双参数或无参数的`onChange()`变体
- 使用`ImageRenderer`渲染SwiftUI视图
- 使用`.sheet(item:)`替代`.sheet(isPresented:)`实现基于模型的内容展示
- Sheet应自行管理操作并在内部调用`dismiss()`
- 使用`ScrollViewReader`结合稳定ID实现程序化滚动
- 避免使用`UIScreen.main.bounds`进行尺寸设置
- 当存在替代方案时（如`containerRelativeFrame()`），避免使用`GeometryReader`

### Swift最佳实践
- 使用现代文本格式化方式（`.format`参数，而非`String(format:)`）
- 对用户输入过滤使用`localizedStandardContains()`（而非`contains()`）
- 优先使用静态成员查找（`.blue`而非`Color.blue`）
- 使用`.task`修饰符自动取消异步任务
- 使用`.task(id:)`处理依赖于特定值的任务

### 视图组合
- **状态变化优先使用修饰符而非条件视图**（保持视图标识的一致性）
- 将复杂视图提取为独立子视图，提升可读性与性能
- 保持视图轻量化以优化性能
- 保持视图`body`简洁且无副作用（不包含复杂逻辑）
- 仅在小型、简单的代码段中使用`@ViewBuilder`函数
- 优先使用`@ViewBuilder let content: Content`而非基于闭包的内容属性
- 将业务逻辑分离到可测试的模型中（不强制特定架构）
- 事件处理函数应引用方法，而非包含内联逻辑
- 使用相对布局而非硬编码常量
- 视图应适配任意上下文（不要假设屏幕尺寸或展示样式）

### 性能优化
- 仅向视图传递所需的值（避免传递大型的"配置"或"上下文"对象）
- 消除不必要的依赖以减少更新扩散
- 在热点路径中，赋值状态前先检查值是否发生变化
- 避免在`onReceive`、`onChange`、滚动处理程序中进行冗余状态更新
- 尽量减少频繁执行代码路径中的工作量
- 大型列表使用`LazyVStack`/`LazyHStack`
- `ForEach`使用稳定标识（动态内容绝不要使用`.indices`）
- 确保`ForEach`每个元素对应的视图数量保持恒定
- 避免在`ForEach`中进行内联过滤（提前过滤并缓存结果）
- 列表行中避免使用`AnyView`
- 考虑使用POD视图实现快速差异对比（或将性能开销大的视图包裹在POD父视图中）
- 当检测到使用`UIImage(data:)`时，建议采用图像降采样作为可选优化方案
- 避免布局抖动（过深的层级、过度使用`GeometryReader`）
- 通过阈值控制频繁的几何更新
- 使用`Self._printChanges()`调试意外的视图更新

### 动画
- 使用带value参数的`.animation(_:value:)`（不带value的废弃版本作用范围过广）
- 事件驱动的动画（按钮点击、手势）使用`withAnimation`
- 为提升性能，优先使用变换（`offset`、`scale`、`rotation`）而非布局变更（`frame`）
- 过渡效果需要在条件结构外部添加动画
- 自定义`Animatable`实现必须包含显式的`animatableData`
- 多步骤序列动画使用`.phaseAnimator`（iOS 17+）
- 需要精确时间控制的动画使用`.keyframeAnimator`（iOS 17+）
- 动画完成处理程序需要使用`.transaction(value:)`以支持重新执行
- 隐式动画会覆盖显式动画（视图树中靠后的动画优先级更高）

### Liquid Glass（iOS 26+）
**仅在用户明确要求时才适配。**
- 使用原生的`glassEffect`、`GlassEffectContainer`和玻璃按钮样式
- 将多个玻璃元素包裹在`GlassEffectContainer`中
- 在布局和视觉修饰符之后应用`.glassEffect()`
- 仅为可点击/可聚焦的元素添加`.interactive()`
- 使用`glassEffectID`结合`@Namespace`实现变形过渡

## 快速参考

### 属性包装器选择（现代方案）
| 包装器 | 使用场景 |
|---------|----------|
| `@State` | 视图内部状态（必须标记为`private`），或自有`@Observable`类 |
| `@Binding` | 子视图需要修改父视图状态 |
| `@Bindable` | 需要绑定的注入式`@Observable`对象 |
| `let` | 来自父视图的只读值 |
| `var` | 通过`.onChange()`监听的只读值 |

**遗留方案（iOS 17之前）：**
| 包装器 | 使用场景 |
|---------|----------|
| `@StateObject` | 视图自有`ObservableObject`（建议使用`@State`搭配`@Observable`替代） |
| `@ObservedObject` | 视图接收的注入式`ObservableObject` |

### 现代API替代方案
| 已废弃API | 现代替代方案 |
|------------|-------------------|
| `foregroundColor()` | `foregroundStyle()` |
| `cornerRadius()` | `clipShape(.rect(cornerRadius:))` |
| `tabItem()` | `Tab` API |
| `onTapGesture()` | `Button`（除非需要获取点击位置或次数） |
| `NavigationView` | `NavigationStack` |
| `onChange(of:) { value in }` | `onChange(of:) { old, new in }` 或 `onChange(of:) { }` |
| `fontWeight(.bold)` | `bold()` |
| `GeometryReader` | `containerRelativeFrame()` 或 `visualEffect()` |
| `showsIndicators: false` | `.scrollIndicators(.hidden)` |
| `String(format: "%.2f", value)` | `Text(value, format: .number.precision(.fractionLength(2)))` |
| `string.contains(search)` | `string.localizedStandardContains(search)`（针对用户输入） |

### Liquid Glass示例代码
```swift
// 基础玻璃效果及降级方案
if #available(iOS 26, *) {
    content
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    content
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}

// 分组玻璃元素
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        GlassButton1()
        GlassButton2()
    }
}

// 玻璃按钮
Button("Confirm") { }
    .buttonStyle(.glassProminent)
```

## 审核检查清单

### 状态管理
- [ ] 新代码使用`@Observable`而非`ObservableObject`
- [ ] `@Observable`类已标记`@MainActor`（若需要）
- [ ] 为`@Observable`类搭配使用`@State`（而非`@StateObject`）
- [ ] `@State`和`@StateObject`属性已标记为`private`
- [ ] 传入的值未被声明为`@State`或`@StateObject`
- [ ] 仅在子视图需要修改父视图状态时使用`@Binding`
- [ ] 为需要绑定的注入式`@Observable`对象使用`@Bindable`
- [ ] 已避免使用嵌套`ObservableObject`（或已直接传递嵌套对象给子视图）

### 现代API（参见`references/modern-apis.md`）
- [ ] 使用`foregroundStyle()`替代`foregroundColor()`
- [ ] 使用`clipShape(.rect(cornerRadius:))`替代`cornerRadius()`
- [ ] 使用`Tab` API替代`tabItem()`
- [ ] 使用`Button`替代`onTapGesture()`（除非需要获取点击位置或次数）
- [ ] 使用`NavigationStack`替代`NavigationView`
- [ ] 已避免使用`UIScreen.main.bounds`
- [ ] 当存在替代方案时已避免使用`GeometryReader`
- [ ] 按钮图片已包含文本标签以支持无障碍访问

### 弹窗与导航（参见`references/sheet-navigation-patterns.md`）
- [ ] 使用`.sheet(item:)`实现基于模型的弹窗
- [ ] 弹窗自行管理操作并在内部关闭
- [ ] 使用`navigationDestination(for:)`实现类型安全的导航

### 滚动视图（参见`references/scroll-patterns.md`）
- [ ] 使用`ScrollViewReader`结合稳定ID实现程序化滚动
- [ ] 使用`.scrollIndicators(.hidden)`替代初始化参数

### 文本与格式化（参见`references/text-formatting.md`）
- [ ] 使用现代文本格式化方式（而非`String(format:)`）
- [ ] 搜索过滤使用`localizedStandardContains()`

### 视图结构（参见`references/view-structure.md`）
- [ ] 使用修饰符而非条件语句处理状态变化
- [ ] 复杂视图已提取为独立子视图
- [ ] 视图保持轻量化以优化性能
- [ ] 容器视图使用`@ViewBuilder let content: Content`

### 性能优化（参见`references/performance-patterns.md`）
- [ ] 视图`body`保持简洁且无副作用
- [ ] 仅传递所需的值（而非大型配置对象）
- [ ] 已消除不必要的依赖
- [ ] 状态更新前已检查值是否发生变化
- [ ] 热点路径已尽量减少状态更新
- [ ] 未在`body`中创建对象
- [ ] 繁重计算已移出`body`

### 列表模式（参见`references/list-patterns.md`）
- [ ] ForEach使用稳定标识（而非`.indices`）
- [ ] ForEach每个元素对应的视图数量保持恒定
- [ ] 未在ForEach中进行内联过滤
- [ ] 列表行中未使用`AnyView`

### 布局（参见`references/layout-best-practices.md`）
- [ ] 已避免布局抖动（过深的层级、过度使用GeometryReader）
- [ ] 通过阈值控制频繁的几何更新
- [ ] 业务逻辑已分离到可测试的模型中
- [ ] 事件处理函数引用方法（而非内联逻辑）
- [ ] 使用相对布局（而非硬编码常量）
- [ ] 视图可适配任意上下文（与上下文无关）

### 动画（参见`references/animation-basics.md`、`references/animation-transitions.md`、`references/animation-advanced.md`）
- [ ] 使用带value参数的`.animation(_:value:)`
- [ ] 事件驱动的动画使用`withAnimation`
- [ ] 过渡效果已搭配条件结构外部的动画
- [ ] 自定义`Animatable`实现包含显式的`animatableData`
- [ ] 为提升性能，优先使用变换而非布局变更
- [ ] 多步骤序列动画使用`.phaseAnimator`（iOS 17+）
- [ ] 需要精确时间控制的动画使用`.keyframeAnimator`（iOS 17+）
- [ ] 动画完成处理程序使用`.transaction(value:)`以支持重新执行

### Liquid Glass（iOS 26+）
- [ ] iOS 26+特性已使用`#available`包裹并提供降级方案
- [ ] 多个玻璃视图已包裹在`GlassEffectContainer`中
- [ ] `.glassEffect()`已在布局/外观修饰符之后应用
- [ ] `.interactive()`仅用于可交互元素
- [ ] 相关元素的形状和色调保持一致

## 参考文档
- `references/state-management.md` - 属性包装器与数据流（优先使用`@Observable`）
- `references/view-structure.md` - 视图组合、提取与容器模式
- `references/performance-patterns.md` - 性能优化技巧与反模式
- `references/list-patterns.md` - ForEach标识、稳定性与列表最佳实践
- `references/layout-best-practices.md` - 布局模式、与上下文无关的视图及可测试性
- `references/modern-apis.md` - 现代API使用与已废弃API替代方案
- `references/animation-basics.md` - 核心动画概念、隐式/显式动画、计时、性能
- `references/animation-transitions.md` - 过渡效果、自定义过渡、Animatable协议
- `references/animation-advanced.md` - 事务、阶段/关键帧动画（iOS 17+）、完成处理程序（iOS 17+）
- `references/sheet-navigation-patterns.md` - 弹窗展示与导航模式
- `references/scroll-patterns.md` - 滚动视图模式与程序化滚动
- `references/text-formatting.md` - 现代文本格式化与字符串操作
- `references/image-optimization.md` - AsyncImage、图像降采样与优化
- `references/liquid-glass.md` - iOS 26+ Liquid Glass API

## 设计理念

本技能聚焦于**事实与最佳实践**，而非架构偏好：
- 不强制特定架构（如MVVM、VIPER）
- 鼓励将业务逻辑分离以提升可测试性
- 优先使用现代API而非已废弃API
- 强调通过`@MainActor`和`@Observable`保证线程安全
- 以性能与可维护性为优化目标
- 遵循Apple的人机界面指南与API设计模式
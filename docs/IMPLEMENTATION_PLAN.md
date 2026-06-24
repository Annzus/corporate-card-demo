# 分阶段实现计划

## 总规则

- 每次只执行一个 Phase。
- Codex 不得一次性完成整个项目。
- 每阶段开始前先解释目标、设计、文件变化和风险。
- 每阶段结束后运行格式化、静态分析和相关测试。
- 每阶段结束后停止，等待用户输入“继续下一阶段”。
- 用户没有理解当前阶段时，不进入下一阶段。

---

## Phase 0：环境检查与执行计划

### 目标

确认本机 Flutter 环境、目标平台和项目目录，不写业务代码。

### 操作

1. 运行并解释：
   - `flutter --version`
   - `dart --version`
   - `flutter doctor -v`
   - `git status`
2. 检查是否已存在 Flutter 工程。
3. 阅读 `AGENTS.md`、`docs/PROJECT_SPEC.md`、本文件。
4. 输出实际执行计划、风险和预计依赖。

### 验收

- 用户知道 Flutter SDK 状态。
- 未修改业务文件。
- 已指出 iOS/Android 工具链问题。

### 必讲概念

- Flutter SDK 与 Dart SDK 的关系。
- iOS Simulator、Android Emulator 和真实设备的差别。
- Flutter 工程中 `lib/`、`ios/`、`android/` 的职责。

---

## Phase 1：创建工程与最小可运行 App

### 目标

建立干净的 Flutter 工程，能在至少一个模拟器运行。

### 操作

1. 创建工程：
   - organization 使用示例域，不使用 UPSIDER 名称。
   - iOS/Android 都保留。
2. 清理默认 Counter Demo。
3. 建立 `app/`、`core/`、`features/` 基础目录。
4. 配置 Material 3 和日语 Locale。
5. 添加基础路由：列表、详情、设置。
6. 创建占位页面。
7. 运行 App。

### 验收

- 首页显示 `利用明細`。
- 可以导航到 `デモ設定` 并返回。
- `flutter analyze` 通过。
- 至少一个 Smoke Widget Test 通过。

### 必讲概念

- `main()`、`runApp()`、根 Widget。
- StatelessWidget/StatefulWidget。
- Widget 不等于 UIView。
- BuildContext 的用途和边界。
- 声明式 UI 与 UIKit 命令式更新的区别。

---

## Phase 2：领域模型与 Fixture 数据

### 目标

建立金额、交易状态、证凭状态和品牌边界。

### 操作

1. 实现 `Money`。
2. 实现 `TransactionStatus`、`ReceiptStatus`。
3. 实现 `Transaction`。
4. 实现 DTO 和 JSON 解析。
5. 创建两个品牌的 Fixture。
6. 定义 `TransactionRepository`。
7. 实现 Fixture Repository。
8. 编写 DTO 映射和品牌隔离单元测试。

### 验收

- 可以按 `brandId` 加载交易。
- 请求 business 时不返回 executive 数据。
- 金额不使用 `double`。
- 未知 status 有明确失败行为。
- 单元测试通过。

### 必讲概念

- Dart class、enum、sealed class。
- `final`、不可变对象、`copyWith` 的目的。
- Swift protocol 与 Dart abstract class 的异同。
- DTO 与 Domain Model 分离的原因。
- 金融金额使用整数的原因。

---

## Phase 3：Riverpod 与明细列表状态

### 目标

从 Repository 加载并展示完整异步状态。

### 操作

1. 添加 Riverpod。
2. 通过 Provider 注入 Repository。
3. 实现 `TransactionListController`。
4. 明确 Loading/Data/Empty/Error。
5. 实现列表页面和列表项。
6. 添加 Retry。
7. 添加错误模拟设置。
8. 编写 Loading/Error/Retry Widget Test。

### 验收

- App 启动显示 Loading 后进入列表。
- 模拟失败时显示日语错误文案。
- Retry 可以恢复。
- 页面不直接 new Repository。

### 必讲概念

- Provider 的 DI 作用。
- AsyncValue 与 RxSwift Observable 的差异。
- 为什么不在 `build()` 里发请求。
- Widget rebuild 的触发机制。
- Provider override 如何帮助测试。

---

## Phase 4：筛选与明细详情

### 目标

完成核心浏览流程。

### 操作

1. 实现交易筛选模型。
2. 添加 `すべて`、`証憑未提出` 等 Chip。
3. 实现日期分组。
4. 实现详情路由。
5. 实现状态 Badge。
6. 实现卡片概要和未提交摘要。
7. 编写筛选单元测试和详情 Widget Test。

### 验收

- 两次点击内进入缺少证凭的交易详情。
- 状态不只依赖颜色。
- 长商户名不破坏布局。
- 返回列表时筛选状态保留。

### 必讲概念

- 派生状态和源状态。
- 为什么筛选不直接修改原始交易列表。
- ListView.builder 与 UITableView 的差别。
- Route 参数与详情加载。

---

## Phase 5：图片选择与证凭表单

### 目标

允许用户选择图片、添加备注，并建立可测试抽象。

### 操作

1. 定义 `ReceiptImagePicker` 接口。
2. 生产实现使用 `image_picker`。
3. 测试实现返回固定示例图片。
4. 实现证凭区域的 missing/selected 状态。
5. 实现备注与 200 字限制。
6. 处理取消选择、权限拒绝、文件读取失败。
7. 编写 Widget Test。

### 验收

- 可从相册选择图片。
- 测试不调用真实系统相册。
- 取消选择不会显示错误。
- 权限/读取失败有明确消息。
- 备注不进入日志和 Analytics。

### 必讲概念

- Plugin 与原生平台桥接。
- 为什么要包装 image_picker 接口。
- 测试替身 Fake/Mock 的差别。
- iOS Info.plist 权限说明。

---

## Phase 6：非阻塞上传、重复防护与 Retry

### 目标

实现本 Demo 最关键的工程能力。

### 操作

1. 定义 `ReceiptUploadRepository`。
2. 实现 Fake 上传，支持进度、延迟、失败模拟。
3. 实现 `UploadJob`。
4. 实现 `UploadQueueController`。
5. 同一交易禁止重复 active job。
6. 生成 `idempotencyKey`。
7. Retry 保留 key。
8. 上传状态从详情页提升为跨页面状态。
9. 列表显示上传状态条。
10. 编写重复提交、失败、重试测试。

### 验收

- 上传时可返回列表并继续操作。
- 双击只创建一个任务。
- 失败后可以重试成功。
- Retry 使用同一 idempotencyKey。
- 页面销毁不会丢失 App 内上传状态。

### 必讲概念

- Future、Stream/回调与异步进度。
- 页面局部状态和应用级业务状态的边界。
- 幂等性解决的真实问题。
- “App 内非阻塞”与“OS 后台上传”的区别。
- 为什么不需要 weak self，同 Swift ARC 有何不同。

---

## Phase 7：Analytics 与体验 KPI

### 目标

证明不仅实现功能，也考虑上线后的验证与改进。

### 操作

1. 定义 Analytics 事件白名单。
2. 实现 DebugAnalyticsService。
3. 在关键动作记录事件。
4. 记录上传时长和 retryCount。
5. 设置页显示最近事件。
6. 测试敏感字段不会进入事件。
7. README 写明 KPI 和改进假设。

### 验收

- 可以查看最近事件。
- 不记录商户名、备注、交易 ID、图片路径。
- 失败与重试有独立事件。
- KPI 有明确计算口径。

### 必讲概念

- 事件埋点与普通日志的差异。
- 最小化数据收集。
- 如何通过数据验证 UX 假设。

---

## Phase 8：多品牌/白标

### 目标

展示可配置品牌体验和严格数据边界。

### 操作

1. 实现 BrandConfig。
2. 实现 BrandController。
3. Business/Executive 两套配置。
4. 所有 Repository 查询显式传 brandId。
5. 品牌切换后重载数据。
6. 旧品牌详情失效处理。
7. 上传任务携带 brandId。
8. 添加品牌隔离单元/Widget Test。

### 验收

- 两品牌 UI 有明显但克制的差异。
- 切换后不存在数据串用。
- 旧品牌详情不会继续展示。
- 不复制真实公司品牌资产。

### 必讲概念

- 配置驱动与复制代码的区别。
- 租户/品牌上下文为何属于数据边界。
- 为什么此阶段不需要 Monorepo。

---

## Phase 9：Golden Test、可访问性与性能检查

### 目标

增强质量证据并进行 UI 自检。

### 操作

1. 列表和详情 Golden Test。
2. Semantics Label。
3. 大文字缩放检查。
4. 长文案与小屏检查。
5. 使用 DevTools 或 rebuild 日志观察不必要重建。
6. 只有在测量确认存在不必要重建后，才使用 Riverpod `select`。

### 验收

- Golden 稳定。
- 核心按钮有语义标签。
- 1.3 倍文字不遮挡上传操作。
- 无明显全页高频重建。

### 必讲概念

- Golden Test 的价值和脆弱性。
- `const` 与 rebuild 的关系。
- 不做没有证据的提前优化。

---

## Phase 10：CI、README 与演示准备

### 目标

形成可提交、可展示、可解释的仓库。

### 操作

1. 添加 GitHub Actions：format check、analyze、test。
2. 完成 README。
3. 添加架构图。
4. 记录 AI 使用方式。
5. 列出已知限制。
6. 准备 5 分钟演示脚本。
7. Codex 做一次只读代码审查。
8. 修复 P0/P1 和明显可维护性问题。

### 验收

- 新环境可按 README 运行。
- CI 通过。
- 用户可以脱离文档说明主要设计。
- 无夸大“真实支付/后台/安全合规”的表述。

---

## Optional Phase 11：AI 备注建议

### 目标

展示 AI 接口边界，不让 AI 成为核心流程单点故障。

### 实现约束

- 定义 `ExpenseMemoSuggestionService`。
- 默认 Fake 基于商户类别返回建议。
- 用户必须确认后才写入备注。
- AI 失败不阻塞证凭上传。
- 不调用真实 API，不上传图片或敏感数据。
- 明确标识“AIによる提案”。

### 面试重点

- 为什么需要 Human-in-the-loop。
- AI 输出不可信时如何验证。
- 为什么 AI 功能必须可降级。

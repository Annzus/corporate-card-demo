# Flutter Demo 开发规格书

## 项目代号

**Corporate Card Companion**

- Flutter 工程名：`corporate_card_companion`
- 展示名称：`BizCard Demo`
- 目标平台：iOS、Android
- UI 语言：日语
- 文档与 Codex 讲解语言：中文
- 代码标识符与代码注释：英文
- 规格版本：1.0
- 设计基准日期：2026-06-24

> 本项目只借鉴法人卡产品的业务问题和工程原则，不复制 UPSIDER 的界面、文案、Logo、配色或专有资产。

---

## 1. 项目目的

制作一个可在面试前展示、也可作为 Flutter 技术课题预演的移动端 Demo，证明以下能力：

1. 能把 Swift/UIKit 的移动端经验迁移到 Flutter。
2. 能理解法人卡客户端的核心业务：利用明细、交易状态、证凭上传、异常恢复。
3. 能做出“操作快、界面不卡、失败可恢复”的移动体验。
4. 能用可测试、可扩展、不过度设计的架构组织代码。
5. 能说明架构和产品决策，而非只展示 AI 生成的结果。
6. 能使用 Codex 提高开发速度，同时保留人工判断、验证和说明责任。

这个 Demo 不证明真实支付清算、授信、反欺诈或会计系统的开发经验。面试时应明确：现有业务经验主要是 iOS 客户端、支付 SDK 集成、回调处理、错误处理、接口联动、测试和维护；本项目用于补充 Flutter 与法人卡领域理解。

---

## 2. 为什么这个题目适合目标岗位

| 目标岗位关注点 | Demo 中的对应设计 |
|---|---|
| Flutter 客户端开发 | 完整 Flutter iOS/Android App |
| 法人卡移动体验 | 利用明细、卡片概要、证凭上传 |
| 从企划到改善 | 用户问题、KPI、事件埋点、改进假设 |
| 小团队端到端负责 | UI、状态、数据层、测试、发布检查均在仓库内 |
| 速度与质量并重 | 非阻塞上传、错误恢复、自动测试、静态分析 |
| 可测试、可扩展架构 | 轻量 Feature-first 分层、Repository 抽象、依赖注入 |
| 多品牌/白标方向 | 所有数据请求携带 `brandId`，品牌配置与数据隔离测试 |
| AI Native 开发文化 | 使用 Codex，但每阶段要求解释、验证、测试和记录 |
| 数据驱动改进 | Analytics 抽象、核心事件、体验 KPI |
| 用户优先 | 打开 App 后快速找到“未提交证凭”的交易并完成上传 |

---

## 3. 产品问题

法人卡使用者完成消费后，经常需要把收据或发票关联到交易明细。主要摩擦包括：

- 打开 App 后找不到需要补证凭的交易。
- 不清楚交易是处理中、已入账、已取消还是已退款。
- 图片上传期间页面卡住，无法继续操作。
- 网络失败后不知道是否已经提交，重复点击可能造成重复请求。
- 多品牌共用系统时，品牌配置和数据边界处理不严谨可能导致数据串用。

Demo 要解决的核心问题：

> 用户在打开 App 后，尽可能少地操作，找到缺少证凭的交易，上传图片，并且即使网络较慢或失败，仍能继续浏览和可靠重试。

---

## 4. 目标用户

### 4.1 员工/持卡人

- 偶尔打开 App。
- 主要任务是查看交易并上传收据。
- 不熟悉复杂财务术语。
- 希望短时间完成操作。

### 4.2 经理或公司负责人

- 需要快速查看卡片使用概况。
- 对等待时间和交互品质敏感。
- 希望在手机端完成基本操作。

会计管理员端不在本次范围内，只通过“证凭未提交”状态体现其业务需求。

---

## 5. 成功标准

### 5.1 产品成功标准

- 用户从 App 首页进入未提交证凭的交易详情，最多两次点击。
- 上传启动后可以返回列表，界面不冻结。
- 上传失败时明确显示失败原因和重试入口。
- 同一交易在上传中不能产生重复任务。
- 切换品牌后只显示当前品牌的数据。

### 5.2 工程成功标准

- `flutter analyze` 无错误和警告。
- `flutter test` 全部通过。
- 核心业务逻辑有单元测试。
- 关键 UI 状态有 Widget Test。
- 至少两个页面有 Golden Test；时间不足时可降为一个。
- 无真实卡号、CVV、PIN、账户、API Key 或用户隐私数据。
- README 能在 5 分钟内说明问题、架构、取舍、测试、AI 使用方式。

---

## 6. 范围分级

### Level A：一面前必须完成

预计 8～12 小时，Codex 辅助下以“理解每一步”为前提。

- 利用明细列表。
- 明细详情。
- 交易状态显示。
- “证凭未提交”筛选。
- 图片选择或示例图片选择。
- 模拟上传。
- Loading、Empty、Error、Retry。
- 上传中禁止重复提交。
- 一个单元测试。
- 一个 Widget Test。
- README。

### Level B：强烈建议完成

追加 4～6 小时。

- 上传不阻塞导航。
- 上传队列与失败重试。
- `idempotencyKey`。
- Analytics 事件与 KPI 定义。
- `brandId` 与两套品牌配置。
- 品牌数据隔离测试。
- Golden Test。
- GitHub Actions 执行 analyze/test。

### Level C：有余力再做

追加 4～8 小时。

- 最多两个并行上传任务。
- 简单的 AI 费用用途/备注建议接口，默认使用 Fake 实现。
- 小型 Mock Backend。
- Integration Test。
- 上传队列本地持久化。

禁止在 Level A 未完成时进入 Level C。

---

## 7. 非目标范围

以下内容明确不做，防止项目失控：

- 真实支付、扣款、授权、清算、退款。
- 真实银行卡 PAN、PIN、CVV 的输入或显示。
- 登录、注册、OAuth、MFA。
- 真实会计系统联动。
- 真实 OCR、LLM、第三方 AI API。
- 真实后台上传和 App 被系统终止后的任务恢复。
- 推送通知。
- 完整后台管理系统。
- 完整多租户 SaaS。
- 复杂动画和高度定制视觉。
- 为了“显得高级”加入不必要的设计模式或大量依赖。
- Monorepo/Melos；单 App 阶段没有实际收益。

---

## 8. 核心用户流程

### Flow A：快速补交证凭

1. 用户打开 App。
2. 首页显示“証憑未提出 3件”。
3. 用户点击“証憑未提出”筛选。
4. 点击目标交易。
5. 点击“証憑を添付”。
6. 选择图片并填写可选备注。
7. 点击“アップロード”。
8. 立即返回可操作状态，页面显示上传进度。
9. 用户返回列表，顶部上传状态条继续更新。
10. 上传完成，交易显示“提出済み”。

### Flow B：失败与重试

1. 用户在 Demo 设置中打开“次回アップロードを失敗させる”。
2. 提交证凭。
3. 上传失败，状态显示“失敗”。
4. 点击“再試行”。
5. 使用同一业务任务的幂等标识重试。
6. 成功后状态更新为“提出済み”。

### Flow C：品牌切换与隔离

1. 打开“デモ設定”。
2. 从 `Business` 切换为 `Executive`。
3. 主题、App 名称、卡片视觉发生变化。
4. 明细重新加载。
5. Business 品牌交易不应出现在 Executive 品牌中。

---

## 9. 页面规格

### 9.1 利用明细列表 `/transactions`

日语标题：`利用明細`

页面内容：

- 当前品牌的卡片概要：
  - 卡片昵称。
  - 后四位，例如 `•••• 4242`。
  - 状态：`利用可能` 或 `一時停止`。
  - 本月利用额，使用整数金额格式化。
- 证凭未提交摘要：`証憑未提出 3件`。
- 筛选 Chip：
  - `すべて`
  - `証憑未提出`
  - `処理中`
  - `確定`
  - `取消・返金`
- 明细按日期分组。
- 每条明细显示：
  - 商户名。
  - 金额。
  - 时间。
  - 交易状态。
  - 证凭状态 Badge。
- 页面状态：
  - Loading：Skeleton 或进度指示。
  - Empty：`該当する明細はありません`。
  - Error：`明細を読み込めませんでした` + `再読み込み`。

交互要求：

- `ListView.builder` 或等价惰性列表。
- 点击明细进入详情。
- 上传任务存在时，页面顶部或底部显示全局上传状态条。
- 不使用颜色作为状态的唯一表达，必须同时显示文字或图标。

### 9.2 利用明细详情 `/transactions/:id`

日语标题：`利用明細詳細`

显示：

- 商户名。
- 金额。
- 利用日期时间。
- 交易状态。
- 卡片昵称与后四位。
- 交易 ID 的简短形式；只用于 Demo 调试。
- 备注。
- 证凭区域。

证凭区域状态：

| 状态 | UI |
|---|---|
| `missing` | `証憑が未提出です` + `証憑を添付` |
| `selected` | 缩略图、文件名、删除、上传按钮 |
| `uploading` | 进度、`アップロード中`，主界面仍可操作 |
| `attached` | 缩略图、`提出済み` |
| `failed` | 错误信息、`再試行`、重新选择 |

备注：

- 可选。
- 最多 200 字。
- 显示字符计数。
- 不将备注内容写入 Analytics 或普通日志。

### 9.3 上传任务状态条

- 有活动任务时显示。
- 展示：文件名或商户名、进度、成功/失败状态。
- 点击可跳到对应明细。
- 多任务阶段可打开上传队列页面；Level A 只需要单任务状态条。

### 9.4 Demo 设置 `/settings`

只用于演示和测试，不是正式产品功能。

- 当前品牌：`Business` / `Executive`。
- 模拟网络延迟：0.3s / 1.5s / 3s。
- 下一次请求失败。
- 下一次上传失败。
- 重置 Mock 数据。
- 查看最近 Analytics 事件。

页面应标记：`デモ専用`。

---

## 10. 交易领域模型

### 10.1 Transaction

```text
Transaction
- id: String
- brandId: String
- cardId: String
- cardNickname: String
- cardLast4: String
- merchantName: String
- amount: Money
- authorizedAt: DateTime
- status: TransactionStatus
- receiptStatus: ReceiptStatus
- memo: String?
- receipt: ReceiptAttachment?
```

### 10.2 Money

```text
Money
- minorUnits: int
- currency: String
```

设计要求：

- 金额禁止使用 `double` 保存。
- JPY 直接使用整数日元。
- 格式化与领域值分离。
- 未支持的币种应有可预测行为，不静默产生错误金额。

### 10.3 TransactionStatus

```text
authorized  -> 処理中
cleared     -> 確定
reversed    -> 取消
refunded    -> 返金
```

含义：

- `authorized`：授权已通过，最终入账信息可能尚未确定。
- `cleared`：商户正式提交交易信息，应用中显示为已确定。
- `reversed`：授权在正式入账前被撤销。
- `refunded`：已确定交易发生后续退款。

Demo 不实现状态转换后台，只展示和测试映射。

### 10.4 ReceiptStatus

```text
missing
selected
uploading
attached
failed
```

### 10.5 UploadJob

```text
UploadJob
- id: String
- transactionId: String
- brandId: String
- localPath: String
- fileName: String
- idempotencyKey: String
- progress: double  // 0.0 - 1.0
- state: UploadJobState
- retryCount: int
- errorMessage: String?
```

业务规则：

- 同一 `transactionId` 同时最多有一个 active job。
- 重复点击不得创建第二个 active job。
- Retry 保留同一个 `idempotencyKey`，表示重试同一业务提交。
- 用户重新选择另一张图片并明确重新提交时，才生成新的 `idempotencyKey`。
- 失败任务可以重试或取消。

### 10.6 BrandConfig

```text
BrandConfig
- id: String
- displayName: String
- shortName: String
- cardLabel: String
- themeSeed: Color
- featureFlags: Set<BrandFeature>
```

初始品牌：

- `business`
- `executive`

约束：

- 每次 repository 查询必须显式传入 `brandId`。
- 不允许先加载所有品牌数据后只在 UI 层过滤。
- Analytics 允许记录非敏感的 `brandId`。
- 自动测试必须验证品牌间数据不会混用。

---

## 11. Mock 数据契约

示例：

```json
{
  "id": "txn_business_001",
  "brandId": "business",
  "cardId": "card_business_01",
  "cardNickname": "開発チームカード",
  "cardLast4": "4242",
  "merchantName": "AWS JAPAN",
  "amountMinor": 12800,
  "currency": "JPY",
  "authorizedAt": "2026-06-22T09:31:00+09:00",
  "status": "cleared",
  "receiptStatus": "missing",
  "memo": null
}
```

Fixture 必须覆盖：

- 已确定、缺少证凭。
- 已确定、已有证凭。
- 处理中。
- 已取消。
- 已退款。
- 长商户名。
- 大金额。
- 同一天多笔交易。
- 两个品牌至少各 6 条数据。

禁止使用：

- 真实公司卡数据。
- 完整卡号。
- 真实用户姓名、地址、邮箱。
- 真实收据照片。

---

## 12. 架构原则

采用“轻量 Feature-first 分层架构”。目标是可解释和可测试，避免为了模仿大型系统而过度设计。

### 12.1 目录结构

```text
lib/
  main.dart
  app/
    app.dart
    router.dart
    app_bootstrap.dart
    brand/
      brand_config.dart
      brand_controller.dart
    theme/
      app_theme.dart
  core/
    analytics/
      analytics_event.dart
      analytics_service.dart
      debug_analytics_service.dart
    errors/
      app_failure.dart
    formatting/
      money_formatter.dart
      date_formatter.dart
    demo/
      demo_settings.dart
      demo_settings_controller.dart
  features/
    transactions/
      domain/
        money.dart
        transaction.dart
        transaction_status.dart
        receipt_status.dart
        transaction_repository.dart
      data/
        transaction_dto.dart
        transaction_fixture_data_source.dart
        transaction_repository_impl.dart
      application/
        transaction_list_controller.dart
        transaction_filter.dart
        transaction_detail_controller.dart
      presentation/
        pages/
          transaction_list_page.dart
          transaction_detail_page.dart
        widgets/
          transaction_list_item.dart
          transaction_status_badge.dart
          receipt_status_badge.dart
          transaction_summary_card.dart
    receipt_upload/
      domain/
        receipt_attachment.dart
        upload_job.dart
        receipt_upload_repository.dart
      data/
        fake_receipt_upload_repository.dart
      application/
        upload_queue_controller.dart
      presentation/
        widgets/
          receipt_attachment_section.dart
          upload_status_banner.dart
    settings/
      presentation/
        demo_settings_page.dart
assets/
  fixtures/
    transactions_business.json
    transactions_executive.json
  demo/
    sample_receipt.png

test/
  core/
  features/
    transactions/
    receipt_upload/
  goldens/
```

### 12.2 各层责任

#### Presentation

- Widget 和页面。
- 把状态渲染成 UI。
- 收集用户操作并调用 Controller。
- 不直接读取 JSON、生成网络结果或处理上传循环。

#### Application

- 页面状态与用例编排。
- 加载、筛选、上传、重试。
- 调用 Repository 与 Analytics。
- 不依赖具体 Widget。

#### Domain

- 领域实体、值对象、枚举、Repository 接口。
- 核心业务规则，如重复上传限制、金额表示。
- 不依赖 Flutter UI。

#### Data

- JSON DTO。
- Fixture/Fake API。
- Repository 实现。
- 将外部数据转换为领域模型。

### 12.3 为什么不建立 UseCase 类

本 Demo 的读取和筛选逻辑较简单。每个动作再创建一个 UseCase 会增加文件数量，却没有明显隔离收益。Controller 可直接依赖 Repository 接口。

未来出现以下情况时再引入 UseCase：

- 同一业务操作被多个入口复用。
- 业务规则跨多个 Repository。
- 需要独立事务边界。
- Controller 开始承担过多业务判断。

此取舍可在面试中用于说明“考虑扩展性，但不机械套用 Clean Architecture”。

---

## 13. 技术栈

### 13.1 必需依赖

- Flutter：使用本机当前 stable，README 记录 `flutter --version`。
- Dart：随 Flutter stable。
- `flutter_riverpod`：状态管理与依赖注入。
- `go_router`：声明式路由与可测试导航。
- `image_picker`：从相册选择示例证凭；测试时注入 Fake。
- `intl`：日语日期与金额格式化。
- `uuid`：生成上传业务的幂等标识。

### 13.2 开发依赖

- `flutter_test`
- `mocktail`
- Flutter 默认 lints
- `integration_test`：Level C

### 13.3 暂不使用

- Freezed/build_runner：初期不使用，避免代码生成掩盖领域建模和增加学习成本。
- Dio/http：Level A 使用 Fake Repository；后续接真实 API 时再引入。
- Hive/Isar/Drift：不做持久化阶段不需要。
- Bloc：Riverpod 已满足需求，不重复引入第二套状态管理。
- GetX：不使用全局隐式依赖。

### 13.4 Riverpod 使用原则

- Repository、Analytics、Image Picker 通过 Provider 注入。
- 异步列表使用 `AsyncNotifier` 或等价 AsyncValue 方案。
- 上传队列使用显式 Controller。
- Widget 只 watch 自己需要的最小状态。
- 能通过 `select` 限制重建时再使用，不能为了“优化”提前复杂化。
- 测试通过 Provider override 注入 Fake。

---

## 14. 数据流

### 14.1 加载明细

```text
TransactionListPage
  -> TransactionListController.load(brandId)
  -> TransactionRepository.fetchTransactions(brandId)
  -> TransactionFixtureDataSource.load(brandId)
  -> DTO -> Domain Model
  -> AsyncData<List<Transaction>>
  -> UI
```

### 14.2 上传证凭

```text
TransactionDetailPage
  -> select image
  -> UploadQueueController.enqueue(...)
  -> duplicate check by transactionId
  -> create UploadJob with idempotencyKey
  -> FakeReceiptUploadRepository.upload(job)
  -> progress stream/callback updates queue
  -> success updates transaction receiptStatus
  -> analytics records success/failure and duration
```

上传必须与页面生命周期解耦。用户离开详情页后，上传状态由全局 `UploadQueueController` 维护，列表状态条仍可显示进度。

这里的“后台”只表示 App 内非阻塞异步处理，不声称支持操作系统级后台上传。

---

## 15. 错误模型

使用 Dart 3 sealed class 或等价明确类型：

```text
AppFailure
- NetworkFailure
- TimeoutFailure
- ValidationFailure
- NotFoundFailure
- DuplicateOperationFailure
- UnknownFailure
```

原则：

- Data 层把低层异常转换为 `AppFailure`。
- UI 不显示原始 exception 或 stack trace。
- 用户文案描述可执行动作。
- 调试日志可记录错误类型和非敏感上下文。
- 文件路径、备注、图片内容、完整交易数据不进入 Analytics。

日语文案示例：

- `通信に失敗しました。時間をおいて再度お試しください。`
- `すでにアップロード中です。`
- `対象の明細が見つかりません。`
- `画像を選択してください。`

---

## 16. 非阻塞上传设计

### Level A

- 一次允许一个上传任务。
- 上传模拟持续 1.5～3 秒。
- 每 100～200ms 更新进度。
- 上传开始后用户可离开详情页。
- 同一交易上传中，按钮禁用。

### Level B/C

- 队列可容纳多个任务。
- 同时最多执行两个。
- 其他任务为 queued。
- 失败不阻塞其他任务。
- Retry 将 failed 任务重新入队。
- 不在 UI isolate 执行图片压缩或大文件同步读取。

性能原则：

- 不在 `build()` 中读取文件、解析大 JSON 或生成昂贵对象。
- 列表使用惰性构建。
- 缩略图设置合理尺寸，避免加载原图到大面积 UI。
- 上传进度只更新必要 Widget，避免整页重建。

---

## 17. 幂等性与重复操作

Demo 无真实服务端，但要通过模型和测试展示理解。

规则：

1. 点击上传时生成 `idempotencyKey`。
2. 同一 active transaction 不允许再次 enqueue。
3. 网络超时后 Retry 使用原 key。
4. Fake Repository 保存已经成功处理的 key；收到同一 key 时返回同一个业务结果，不创建第二份附件。
5. 用户明确删除已选图片并重新选择后，产生新的业务提交和新 key。

测试案例：

- 双击上传只产生一个任务。
- 同一个 key 调用两次，只产生一个附件结果。
- Retry 后状态从 failed 变为 attached。

---

## 18. 多品牌/白标设计

### 18.1 目标

证明理解“同一基础能力支持不同品牌体验”及其边界，而不是制作两个独立 App。

### 18.2 实现

- App 启动时由 `BrandController` 提供当前 `BrandConfig`。
- Repository 方法必须传 `brandId`。
- Fixture 文件按品牌分开。
- 路由不携带敏感租户信息；业务调用从当前品牌上下文读取。
- 主题、AppBar 标题、卡片样式、可选功能由配置决定。
- Debug 设置允许切换品牌，切换后清空当前列表缓存并重新加载。

### 18.3 安全检查

- 请求 A 品牌数据时不得返回 B 品牌交易。
- 切换品牌时，详情页若仍指向旧品牌交易，应返回列表或显示 NotFound，而非展示旧数据。
- 上传任务必须记录 brandId；不能把 A 品牌图片关联到 B 品牌交易。

### 18.4 为什么不使用 Monorepo

只有一个 Demo App 与共享代码时，Monorepo 增加配置和维护成本。若未来真正增加两个独立品牌 App、共享 package 与各自发布流水线，再评估 Melos/Monorepo。

---

## 19. Analytics 与产品改善

### 19.1 事件

```text
app_opened
transaction_list_viewed
transaction_filter_changed
transaction_detail_opened
receipt_attach_tapped
receipt_image_selected
receipt_upload_started
receipt_upload_succeeded
receipt_upload_failed
receipt_upload_retried
brand_switched
```

允许属性：

- `brandId`
- `transactionStatus`
- `receiptStatus`
- `durationMs`
- `retryCount`
- `errorType`

禁止属性：

- 商户名。
- 备注。
- 图片路径或内容。
- 卡片后四位。
- 交易 ID 原值。
- 金额；Demo 中也不记录，减少不必要数据。

### 19.2 KPI

- `Time to Receipt Upload`：从 App 打开到首次上传成功的时间。
- `Upload Success Rate`：上传成功数 / 上传开始数。
- `Retry Rate`：发生 retry 的上传占比。
- `Missing Receipt Completion Rate`：进入未提交筛选后完成上传的比例。
- `Time on Task`：进入详情到上传启动的时间。

### 19.3 改进假设示例

- 将“证凭未提交”摘要放在首页顶部，可能缩短找到目标交易的时间。
- 上传启动后允许继续操作，可能降低中途退出率。
- 错误信息提供直接 Retry，可能提高完成率。

Demo 只实现 Debug Analytics，并在设置页显示最近事件，不接真实第三方 SDK。

---

## 20. UI/UX 原则

- 使用 Material 3，但尊重 iOS 返回手势、Safe Area、键盘和图片选择行为。
- 首屏重点突出“证凭未提交”，不堆叠过多仪表盘。
- 用户完成任务的路径优先于视觉装饰。
- 点击目标至少约 44x44 logical pixels。
- 支持系统字体放大到约 1.3 倍时不截断关键操作。
- 状态使用“图标 + 文本 + 可选颜色”。
- 动画 150～250ms，避免影响效率。
- 上传成功可使用轻微反馈，不制作复杂庆祝动画。
- 错误信息就近显示，并提供下一步动作。
- 表单提交时保留用户已输入备注。

不使用 UPSIDER 的品牌色和真实 UI 截图作为复刻目标。

---

## 21. 测试策略

### 21.1 单元测试

必须：

1. `Money` 不使用浮点并正确格式化 JPY。
2. 交易筛选逻辑。
3. DTO 到 Domain 映射。
4. 同一交易重复上传被拒绝。
5. Retry 保持 idempotencyKey。
6. 品牌隔离。

推荐：

7. Analytics 不含敏感字段。
8. 上传失败不影响其他任务。
9. 状态到日语标签映射。

### 21.2 Widget Test

必须：

- 列表 Loading -> Data。
- Error 状态点击 `再読み込み` 后成功。
- `証憑未提出` 筛选只显示目标数据。
- 详情页上传中按钮禁用。

推荐：

- 离开详情页后上传状态条仍显示。
- 上传失败后可点击 `再試行`。
- 品牌切换后 UI 与数据变化。

### 21.3 Golden Test

目标页面：

- 利用明细列表：正常状态。
- 明细详情：证凭未提交状态。

要求：

- 固定测试尺寸和文本缩放。
- 不依赖网络图片。
- 运行环境差异导致不稳定时，记录原因；不要为了“有 Golden”而保留频繁误报的测试。

### 21.4 Integration Test

Level C：

- 打开 App。
- 筛选证凭未提交。
- 进入详情。
- 选择示例图片。
- 上传。
- 返回列表。
- 等待完成。
- 确认状态为已提交。

---

## 22. 安全与隐私

- 只显示卡片后四位。
- 不实现 PAN、PIN、CVV。
- 不提交 `.env`、Key、Token。
- 日志不写图片内容、备注、完整交易对象。
- Analytics 采用白名单属性。
- Fixture 使用虚构数据。
- 上传 API 接口保留 `brandId` 和 `idempotencyKey`，但无真实服务器。
- 图片选择权限文案必须说明用途。
- 依赖加入前检查维护状态、许可证和必要性。
- 不在 README 中声称符合 PCI DSS；Demo 只体现基础安全意识。

---

## 23. 可访问性

- 交易状态 Badge 添加 Semantics Label。
- 图片按钮提供可读标签。
- 进度不仅靠动画，显示百分比或明确文本。
- 错误信息可被屏幕阅读器读取。
- 页面标题结构明确。
- 测试至少覆盖一次较大文字缩放。

---

## 24. 代码规范

- 一个文件原则上只承担一个主要职责。
- Widget 超过约 100～150 行时评估拆分，不机械按行数拆。
- 禁止在页面中直接 new Repository。
- 禁止在 `build()` 中调用异步业务方法。
- 禁止使用 `dynamic` 绕过类型设计，JSON 边界除外且应立即转换。
- 公共业务规则必须有测试。
- 公共命名使用英文且含义明确。
- 代码注释解释“为什么”，不重复代码表面行为。
- 不保留无意义 TODO。
- 不提交生成目录、构建产物或真实图片隐私数据。

---

## 25. Definition of Done

一项功能只有满足以下条件才算完成：

- 功能符合本规格。
- 成功、空、加载、失败状态均考虑。
- 关键异常路径有处理。
- 新业务逻辑有测试。
- `dart format .` 通过。
- `flutter analyze` 通过。
- `flutter test` 通过。
- Codex 已说明：改了什么、为什么这样设计、替代方案、风险。
- 用户能用自己的话解释主要设计，不依赖照读文档。

---

## 26. README 必须包含

1. 项目要解决的问题。
2. Demo 截图或 GIF；时间不足可后补。
3. 运行环境与命令。
4. 功能列表。
5. 架构图或目录说明。
6. 关键设计决策：
   - 为什么用 Riverpod。
   - 为什么金额用整数。
   - 为什么上传与页面生命周期分离。
   - 为什么使用 idempotencyKey。
   - 为什么显式传 brandId。
   - 为什么没有真实支付和后台。
7. 测试策略与执行结果。
8. Analytics 与 KPI。
9. AI/Codex 使用记录：
   - 哪些工作由 Codex 辅助。
   - 自己如何审查。
   - 哪些决策由自己做。
10. 已知限制和下一步。

---

## 27. 5 分钟演示脚本

### 0:00～0:40 问题

“这是一个面向法人卡持卡员工的证凭提交 Demo。目标是让不经常打开 App 的用户，也能快速找到缺少证凭的交易，并在网络较慢时继续操作。”

### 0:40～1:40 核心流程

- 打开首页。
- 点击 `証憑未提出`。
- 进入交易详情。
- 选择证凭并上传。

### 1:40～2:30 非阻塞与失败恢复

- 上传中返回列表。
- 展示全局上传状态条。
- 模拟一次失败并 Retry。
- 说明重复点击防护和 idempotencyKey。

### 2:30～3:20 多品牌

- 切换 Business/Executive。
- 展示主题与数据变化。
- 说明所有 Repository 查询显式携带 brandId，并有隔离测试。

### 3:20～4:20 架构与测试

- 展示 Feature-first 目录。
- 说明 Controller、Repository、Fake 数据层。
- 展示 unit/widget/golden 测试。

### 4:20～5:00 产品改善与 AI 使用

- 展示 Analytics 事件。
- 说明 KPI。
- 说明 Codex 用于加速实现，但架构、范围、安全和最终验证由自己负责。

---

## 28. 面试可能追问

### 为什么选择 Riverpod？

参考回答：

“我需要同时解决状态管理和依赖替换。Repository、Analytics、图片选择器都通过 Provider 注入，测试时可以 override。项目规模不大，所以没有引入更复杂的事件层。若团队已有 Bloc 标准，我也会遵循团队约定。”

### 为什么不直接把上传状态放在详情页面？

“用户离开详情页后上传仍应继续，状态属于跨页面业务任务。放在页面局部状态会绑定 Widget 生命周期，因此提取为全局 UploadQueueController。”

### 这是真正的后台上传吗？

“不是。当前实现是 App 进程内的非阻塞异步上传。要支持系统终止后的恢复，需要原生后台任务、持久化队列和服务端状态确认，本 Demo 没有夸大这一点。”

### 为什么金额不用 double？

“金融金额不能接受浮点精度误差，所以领域模型使用最小货币单位的整数。JPY 是整数日元，格式化在展示层处理。”

### idempotencyKey 有什么作用？

“网络超时时，客户端不知道服务端是否已经成功。重试同一业务请求时使用相同 key，服务端可以返回原结果，避免重复创建。”

### 为什么显式传 brandId？

“品牌是数据边界和规则上下文。若只在 UI 层过滤，底层可能加载或误用其他品牌数据。Repository 接口显式要求 brandId，并通过测试验证隔离。”

### 为什么没接真实后端？

“一面前的目标是证明 Flutter 客户端、状态管理、异常恢复和设计能力。真实后端会扩大范围，但接口已经通过 Repository 隔离，后续可替换为 HTTP 实现。”

### Codex 写了多少？

“Codex 辅助脚手架、测试样板和部分实现。我要求它逐阶段解释，并亲自检查依赖、状态流、边界条件、测试结果和每个设计决定。面试中展示的代码我都能解释。”

---

## 29. Swift/UIKit 对照学习点

| Flutter/Dart | Swift/UIKit/RxSwift 类比 | 注意 |
|---|---|---|
| Widget | UIView/UIViewController 的 UI 描述职责 | Widget 是不可变配置，不等于 UIView 实例 |
| State | ViewModel/UI State | 状态改变后框架重建相关 Widget |
| Riverpod Provider | DI 容器 + Observable 状态入口 | 不等同于全局单例 |
| AsyncValue | loading/success/error 状态枚举 | 把异步状态显式化 |
| ListView.builder | UITableView/UICollectionView 的惰性 Cell | Flutter 通过 Widget 构建，不复用 Cell 机制 |
| abstract class Repository | Swift protocol | 用于依赖反转和测试替换 |
| Future | async/await Task | Dart 与 Swift 的并发模型不同 |
| Stream | RxSwift Observable 的部分用途 | 不应把所有状态都做成 Stream |
| BuildContext | 当前 Widget 树位置的句柄 | 不应跨异步长期保存 |
| const Widget | 可复用的不可变配置 | 有助于减少不必要创建，但不是性能万能药 |

Codex 每阶段应使用这些类比讲解，但必须说明差异，避免错误等同。

---

## 30. 参考资料

设计依据来自以下公开内容：

- UPSIDER Mobile App Engineer 招聘页。
- 《データ分析からリリースまで丸ごと担う――自給自足するモバイルチームを目指すエンジニアリングマネージャーの挑戦》。
- 《未来のFintechインフラはどうつくられるのか？──UPSIDERの技術戦略とプラットフォーム構想》。
- 《Flutterと歩んだ僕たちの最高のアプリの作り方》。

此规格针对公开信号设计，不代表 UPSIDER 实际技术课题题目。

# CasePilot 用户教程

本教程帮助你从零开始使用 CasePilot 插件，从需求文档自动生成测试用例。

## 1. Claude Code 简介

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) 是 Anthropic 推出的 CLI 工具，可以在终端中与 Claude 进行交互式对话，完成代码编写、文档处理等任务。

CasePilot 是 Claude Code 的插件，扩展了 Claude Code 的能力，使其能够从需求文档自动生成结构化的测试用例。

## 2. 前置准备

### 2.1 安装 Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

安装完成后，运行 `claude` 命令启动 CLI 并完成账户认证。

### 2.2 配置飞书 MCP 服务（可选）

如果你需要从飞书项目单或飞书云文档读取需求，需要配置对应的 MCP 服务器。使用本地文件作为输入则可跳过此步骤。

| 输入源 | 所需 MCP 服务器 | 用途 |
|--------|----------------|------|
| 飞书项目单 | `lark-prj-remote` | 读取飞书项目中的工作项 |
| 飞书云文档 | `lark-mcp-remote` | 读取飞书云文档内容 |
| 本地文件 | 无 | 直接读取本地 Markdown 等文件 |

MCP 服务器的配置方式请参考各服务器的官方文档。配置完成后，可使用 `/casepilot:check-mcp` 命令验证配置状态。

## 3. 安装插件

### 3.1 通过 Marketplace 安装（推荐）

在 Claude Code 中依次执行：

```bash
# 添加插件市场
/plugin marketplace add mookechee/mookechee-cc-plugins

# 安装 CasePilot 插件
/plugin install casepilot@mookechee-cc-plugins
```

或使用交互式界面：

```bash
/plugin
```

在 **Discover** 标签页中找到 CasePilot 并安装。

### 3.2 本地开发模式安装

如果你需要对插件进行修改或调试：

```bash
claude --plugin-dir /path/to/mookechee-cc-plugins
```

### 3.3 验证安装

安装完成后，在 Claude Code 中输入 `/casepilot:check-mcp`，如果命令被识别并执行，说明插件已正确安装。

## 4. 使用教程

### 4.1 检查 MCP 配置

```bash
/casepilot:check-mcp
```

该命令会检测当前环境中 MCP 服务器的配置状态，并提示缺失的服务。

### 4.2 生成测试用例

使用 `/casepilot:generate` 命令，后跟输入源路径：

#### 从飞书项目单生成

```bash
/casepilot:generate https://project.feishu.cn/xxx/story/detail/xxx
```

需要 `lark-prj-remote` MCP 服务器。

#### 从飞书云文档生成

```bash
/casepilot:generate https://xxx.feishu.cn/docx/xxx
```

需要 `lark-mcp-remote` MCP 服务器。

#### 从本地文件生成

```bash
/casepilot:generate ./docs/requirement.md
```

无需任何 MCP 服务器。

### 4.3 自然语言方式

除了命令方式，你也可以直接用自然语言描述需求：

```
帮我为这个需求生成测试用例：[需求描述]

请根据这个飞书项目单生成测试用例：[URL]
```

## 5. 工作流程详解

CasePilot 采用四阶段渐进式生成流程：

### 阶段1：需求分析

将需求文档拆分为独立、可测试的需求点。

### 阶段2：测试点生成

基于二八法则，为每个需求点生成 3-8 个测试点，覆盖以下测试类型：

- PRD UI/交互设计测试（P0）
- 功能测试（P0）
- 状态切换测试（P0-P1）
- 边界值测试（P1）
- 异常场景测试（P0-P1）
- 兼容性测试（P1-P2）

### 阶段3：用例设计

为每个测试点设计测试用例，采用 7 层链式结构：标题 → 模块 → 用例名称 → 前置条件 → 执行步骤 → 预期结果 → 优先级。

### 阶段4：智能优化

进行验收标准覆盖检查，确保每条验收标准都有对应的测试用例。

### 用户交互点

在生成过程中，CasePilot 会在关键节点与你确认：

- 需求分析完成后，确认需求点是否完整
- 测试点生成后，确认覆盖范围是否合理

### 输出文件

生成的测试用例保存为 Markdown 文件：

```
~/Testcase/markmap/{工作项名称}_测试用例_{时间戳}.md
```

文件可用 VS Code markmap 插件或其他 markmap 工具渲染为思维导图。

生成完成后会输出统计摘要，包括：

- 需求摘要（名称、描述、验收标准）
- 验收标准覆盖情况表格
- 测试用例统计（按分类和优先级）
- 文件路径

## 6. 最佳实践

### 需求文档编写建议

- 需求描述应清晰具体，避免模糊表述
- 包含明确的验收标准，CasePilot 会据此进行覆盖检查
- 拆分粒度适中，一个需求文档聚焦一个功能模块

### 常见问题

**Q: MCP 服务未配置怎么办？**

运行 `/casepilot:check-mcp` 查看配置状态和指引。本地文件模式不需要任何 MCP 服务器。

**Q: 生成的 Markdown 文件如何查看？**

可用 VS Code 的 markmap 插件渲染为思维导图，也可以直接作为 Markdown 文档阅读。

**Q: 支持哪些格式的本地文件？**

支持 Markdown 等文本格式的文件作为输入。

## 更多信息

- [插件详细功能文档](../plugins/casepilot/README.md)
- [仓库主页](../README.md)

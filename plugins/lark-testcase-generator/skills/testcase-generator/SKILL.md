---
name: lark-testcase-generator
description: 从飞书项目单子自动生成OPML格式的XMind测试用例。通过飞书项目MCP读取需求描述、验收标准和技术设计文档，梳理用户操作流程后生成结构化测试用例。在用户需要为飞书项目单子生成测试用例、创建XMind思维导图测试用例或需要OPML格式测试文档时使用。
---

# 飞书项目测试用例生成器

自动从飞书项目单子生成 OPML 格式的 XMind 测试用例文件。

## MCP 服务器依赖

**重要**：此 Skill 依赖以下 MCP 服务器，使用前请确保已配置：

| MCP 服务器 | 用途 | 必需 |
|-----------|------|------|
| `lark-prj-remote` | 读取飞书项目单子（描述、验收标准） | 是 |
| `lark-mcp-remote` | 读取飞书云文档（技术设计文档） | 是 |

### 检测 MCP 配置

在使用此 Skill 前，首先检测 MCP 是否已配置：

1. 尝试调用 `mcp__lark-prj-remote__get_workitem_info` 或 `mcp__lark-mcp-remote__docx_builtin_search`
2. 如果返回 "MCP server not found" 或类似错误，说明未配置
3. 此时应引导用户配置 MCP

### 引导用户配置 MCP

如果检测到 MCP 未配置，请输出以下引导信息：

```
检测到飞书 MCP 服务器未配置。

请按以下步骤配置：

1. 获取飞书应用凭证：
   - 访问 https://open.feishu.cn/
   - 创建应用并获取 App ID 和 App Secret

2. 配置飞书项目 MCP (lark-prj-remote)：

   claude mcp add --transport stdio lark-prj-remote \
     --env LARK_APP_ID=YOUR_APP_ID \
     --env LARK_APP_SECRET=YOUR_APP_SECRET \
     -- npx -y @anthropic/claude-code-mcp-lark-prj

3. 配置飞书文档 MCP (lark-mcp-remote)：

   claude mcp add --transport stdio lark-mcp-remote \
     --env LARK_APP_ID=YOUR_APP_ID \
     --env LARK_APP_SECRET=YOUR_APP_SECRET \
     -- npx -y @anthropic/claude-code-mcp-lark

4. 重启 Claude Code 后重试

或者运行 /lark-testcase-generator:check-mcp 查看详细配置指南。
```

## 功能概述

1. 通过飞书项目 MCP 读取单子信息（描述、验收标准）
2. 通过飞书 MCP 读取技术方案设计文档
3. 搜索相关测试用例参考
4. 梳理用户操作流程和逻辑分支
5. 生成 OPML 格式的 XMind 测试用例

## 使用流程

### 第一步：解析飞书项目 URL

从用户提供的 URL 中提取：
- `project_key`: 项目空间标识
- `work_item_id`: 工作项 ID

**URL 格式示例：**
```
https://project.feishu.cn/{project_key}/story/detail/{work_item_id}
https://project.feishu.cn/uts5wn/story/detail/6596729761
```

### 第二步：获取单子信息

使用飞书项目 MCP 工具：

```
mcp__lark-prj-remote__get_workitem_brief
  - project_key: 从 URL 提取
  - work_item_id: 从 URL 提取
  - fields: ["description", "field_803289", "field_13a9cf", "field_3437d3"]
```

关键字段：
- `description`: 需求描述
- `field_803289`: 验收标准
- `field_13a9cf`: 技术设计文档链接
- `field_3437d3`: Server技术文档链接

### 第三步：读取技术设计文档

如果存在技术设计文档链接，使用飞书 MCP 读取：

```
mcp__lark-mcp-remote__docs_v1_content_get
  - query:
      doc_token: 从链接提取 (如: JPIIwy2haiiAdrkjo4IcSlSennh)
      doc_type: docx
      content_type: markdown
```

### 第四步：梳理用户操作流程

基于获取的信息，梳理：

1. **功能模块划分**
   - 识别独立的功能单元
   - 确定模块间的依赖关系

2. **状态机流程**（如适用）
   - 识别状态转换
   - 确定触发条件
   - 确定每个状态的验证点

3. **用户操作路径**
   - 正向流程（Happy Path）
   - 异常流程（Error Path）
   - 边界条件

### 第五步：生成测试用例

按以下分类生成测试用例：

1. **编译/构建测试**（P0）
2. **核心功能测试**（P0）
3. **配置与参数测试**（P1）
4. **异常处理测试**（P1）
5. **集成测试**（P0-P1）
6. **性能/资源测试**（P1-P2）

### 第六步：输出 OPML 文件

生成路径：`~/Testcase/opml/{project-name}-testcase.opml`

## 测试用例格式规范

### 结构要求

每条测试用例采用链式结构：

```
用例名称
  └── 前置条件
        └── 执行步骤
              └── 预期结果
                    └── 优先级
```

### OPML 格式示例

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>测试用例标题</title>
    <dateCreated>2025-12-24</dateCreated>
  </head>
  <body>
    <outline text="测试用例集">
      <outline text="功能模块">
        <outline text="测试用例名称">
          <outline text="前置条件描述">
            <outline text="执行步骤描述">
              <outline text="预期结果描述">
                <outline text="P0"/>
              </outline>
            </outline>
          </outline>
        </outline>
      </outline>
    </outline>
  </body>
</opml>
```

### 优先级定义

| 优先级 | 说明 | 适用场景 |
|--------|------|----------|
| P0 | 核心功能，必须测试 | 编译验证、主流程、关键状态转换 |
| P1 | 重要功能，应该测试 | 配置参数、异常处理、边界条件 |
| P2 | 次要功能，可选测试 | 辅助功能、日志调试 |

## 测试用例编写原则

### 用例名称
- 简洁明了，格式：`{功能点}{测试场景}`
- 例：`HELLO请求正常处理-Discovered状态`

### 前置条件
- 说明测试开始前必须满足的条件
- 例：`DeviceServer处于Discovered状态（已完成DISCOVER）`

### 执行步骤
- 具体的操作步骤，一个步骤一个动作
- 例：`发送HELLO请求（heartbeat_interval_ms=1000）`

### 预期结果
- 明确、可量化、可观测的验证点
- 例：`服务端返回HELLO响应，包含session_id，状态变为Active`

## 触发关键词

以下关键词会触发此 Skill：

- "生成测试用例"
- "OPML 测试用例"
- "XMind 测试用例"
- "飞书项目单子测试"
- "为这个需求生成用例"
- "创建测试用例思维导图"
- 提供飞书项目 URL

## 示例

### 输入示例

```
帮我为这个飞书项目单子生成测试用例：
https://project.feishu.cn/uts5wn/story/detail/6596729761
```

### 处理流程

1. 解析得到 `project_key=uts5wn`, `work_item_id=6596729761`
2. 调用 MCP 获取单子信息
3. 解析技术设计文档链接，获取文档内容
4. 识别功能模块和状态流程
5. 生成分类测试用例

### 输出

生成 OPML 文件 `~/Testcase/opml/wuji-sdk-server-testcase.opml`

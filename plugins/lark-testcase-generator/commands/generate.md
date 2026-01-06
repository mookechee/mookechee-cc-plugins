---
description: 从飞书项目单子生成OPML格式的XMind测试用例。需要配置飞书MCP服务器（lark-prj-remote 和 lark-mcp-remote）。
---

# 生成测试用例

从飞书项目单子 "$ARGUMENTS" 自动生成 OPML 格式的 XMind 测试用例。

## 前置要求：MCP 服务器配置

此命令需要以下 MCP 服务器：

| MCP 服务器 | 用途 |
|-----------|------|
| `lark-prj-remote` | 读取飞书项目单子信息（描述、验收标准） |
| `lark-mcp-remote` | 读取飞书云文档（技术设计文档） |

运行 `/mcp` 查看当前已配置的 MCP 服务器。

## 用法

```
/lark-testcase-generator:generate <飞书项目URL>
```

### 示例

```bash
/lark-testcase-generator:generate https://project.feishu.cn/uts5wn/story/detail/6589464068
```

---

## 执行流程（必须严格按顺序执行）

### 步骤 1: 解析 URL 参数

从 "$ARGUMENTS" 中提取：
- `project_key`: 空间标识（如 `uts5wn`）
- `work_item_id`: 工作项 ID（如 `6589464068`）

URL 格式：`https://project.feishu.cn/{project_key}/story/detail/{work_item_id}`

### 步骤 2: 获取工作项基本信息

调用 `mcp__lark-prj-remote__get_workitem_brief`:

```
project_key: {提取的project_key}
work_item_id: {提取的work_item_id}
```

获取工作项名称和基本信息。

### 步骤 3: 获取需求详细字段

再次调用 `mcp__lark-prj-remote__get_workitem_brief`，指定字段：

```
project_key: {project_key}
work_item_id: {work_item_id}
fields: ["description", "field_803289", "field_13a9cf", "wiki"]
```

字段说明：
- `description`: 需求描述
- `field_803289`: 验收标准
- `field_13a9cf`: 技术设计文档链接

### 步骤 4: 读取技术设计文档

如果 `field_13a9cf`（技术设计文档链接）存在：

1. 从链接中提取 doc_token（链接最后一段，如 `BI8EwMrSQiLOWfkzvFycZy2ZnHh`）
2. 调用 `mcp__lark-mcp-remote__docs_v1_content_get`:

```
query:
  doc_token: {提取的doc_token}
  doc_type: docx
  content_type: markdown
```

### 步骤 5: 梳理用户操作流程

根据获取的信息，内部分析：

1. **识别主要功能模块**
   - 列出所有功能点
   - 确定功能之间的关系

2. **绘制用户操作路径**
   - 主流程路径
   - 分支流程路径
   - 异常处理路径

3. **识别状态切换点**
   - 初始状态
   - 中间状态
   - 终止状态
   - 状态转换条件

### 步骤 6: 设计测试用例

按以下分类设计测试用例：

| 分类 | 说明 | 典型优先级 |
|------|------|-----------|
| UI显示测试 | 界面元素、颜色、文案、布局 | P0-P1 |
| 功能测试 | 核心功能验证 | P0 |
| 状态切换测试 | 状态转换正确性 | P0-P1 |
| 边界值测试 | 最大值、最小值、默认值 | P1 |
| 异常场景测试 | 错误处理、异常恢复 | P0-P1 |
| 兼容性测试 | 多语言、多设备、多配置 | P1-P2 |
| 稳定性测试 | 重复操作、极端场景 | P2 |

### 步骤 7: 生成 OPML 文件

生成的 OPML 文件必须符合以下结构：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>{工作项名称}测试用例</title>
  </head>
  <body>
    <outline text="{工作项名称}测试用例">
      <!-- 每条测试用例是一个链式结构 -->
      <outline text="用例名称">
        <outline text="前置条件描述">
          <outline text="执行步骤描述">
            <outline text="预期结果描述">
              <outline text="P0"/>  <!-- 或 P1、P2 -->
            </outline>
          </outline>
        </outline>
      </outline>
      <!-- 更多用例... -->
    </outline>
  </body>
</opml>
```

**关键要求：**
- 每条用例是一个链式结构（branch）：`用例名称 → 前置条件 → 执行步骤 → 预期结果 → 优先级`
- 每个节点是前一个的子节点
- 优先级使用大写 P + 数字：P0、P1、P2
- P0 最重要（核心功能），P2 最次要（辅助功能）

### 步骤 8: 保存文件

将 OPML 文件保存到：`~/Testcase/opml/{工作项名称}_测试用例.opml`

如果目录不存在，先创建目录。

### 步骤 9: 输出总结

输出格式化的总结信息：

```markdown
## 需求摘要

**需求名称**：{工作项名称} (m-{work_item_id})
**需求描述**：{description}
**验收标准**：
1. {验收标准1}
2. {验收标准2}
...

## 测试用例统计

| 分类 | 用例数 | P0 | P1 | P2 |
|------|--------|----|----|-----|
| {分类1} | X | X | X | X |
| {分类2} | X | X | X | X |
| **合计** | **X** | **X** | **X** | **X** |

## 文件路径

`~/Testcase/opml/{工作项名称}_测试用例.opml`
```

---

## 优先级说明

| 优先级 | 重要性 | 适用场景 |
|--------|--------|----------|
| **P0** | 最高 | 核心功能、验收标准直接相关、主流程、编译验证 |
| **P1** | 中等 | 重要功能、边界条件、配置验证、异常处理 |
| **P2** | 较低 | 辅助功能、极端场景、稳定性测试、可选特性 |

---

## 测试场景设计方法

### 1. 等价类划分
- 有效等价类：正常输入
- 无效等价类：异常输入

### 2. 边界值分析
- 最小值、最小值+1
- 最大值、最大值-1
- 默认值

### 3. 状态转换测试
- 覆盖所有状态
- 覆盖所有转换路径
- 测试无效转换

### 4. 错误猜测
- 文件缺失
- 网络异常
- 权限不足
- 资源不足

---

## 注意事项

1. 确保飞书 MCP 服务已配置并可用
2. 需要有权限访问对应的飞书项目单和云文档
3. 技术设计文档必须是飞书云文档格式（docx）
4. 生成的 OPML 文件可直接导入 XMind 8 或更高版本查看
5. 测试用例应覆盖验收标准中的所有要点

---
description: 检查飞书MCP服务器配置状态，并提供配置指引。
---

# 检查 MCP 配置

检查 casepilot 插件所需的 MCP 服务器是否已正确配置。

## 依赖的 MCP 服务器

| MCP 服务器 | 用途 | 必需 |
|-----------|------|------|
| `lark-prj-remote` | 读取飞书项目单子信息 | 可选（使用飞书项目单时需要） |
| `lark-mcp-remote` | 读取飞书云文档内容 | 可选（使用飞书文档时需要） |

## 检查流程

### 步骤 1：检查 lark-prj-remote

尝试调用 `mcp__lark-prj-remote__get_workitem_info`，参数：
```json
{
  "work_item_type": "story"
}
```

- **成功**：显示 ✅ lark-prj-remote 已配置
- **失败**：显示 ❌ lark-prj-remote 未配置，提供配置指引

### 步骤 2：检查 lark-mcp-remote

尝试调用 `mcp__lark-mcp-remote__wiki_v2_space_list`，参数：
```json
{
  "query": {}
}
```

- **成功**：显示 ✅ lark-mcp-remote 已配置
- **失败**：显示 ❌ lark-mcp-remote 未配置，提供配置指引

### 步骤 3：输出检查结果

```
🔍 MCP 服务器配置检查结果

✅ lark-prj-remote: 已配置
   - 可使用飞书项目单 URL 生成测试用例

❌ lark-mcp-remote: 未配置
   - 无法使用飞书云文档 URL 生成测试用例
   - 配置方法见下方指引

📝 本地文件模式: 始终可用
   - 可直接使用本地 .md/.txt 文件生成测试用例
```

## 配置指引

### 配置 lark-prj-remote

1. 获取飞书项目的 API 凭证
2. 在 Claude Code 设置中添加 MCP 服务器：

```json
{
  "mcpServers": {
    "lark-prj-remote": {
      "command": "npx",
      "args": ["-y", "@anthropic/lark-prj-mcp"],
      "env": {
        "LARK_APP_ID": "你的AppID",
        "LARK_APP_SECRET": "你的AppSecret",
        "LARK_PROJECT_KEY": "你的项目Key"
      }
    }
  }
}
```

### 配置 lark-mcp-remote

1. 获取飞书云文档的 API 凭证
2. 在 Claude Code 设置中添加 MCP 服务器：

```json
{
  "mcpServers": {
    "lark-mcp-remote": {
      "command": "npx",
      "args": ["-y", "@anthropic/lark-mcp"],
      "env": {
        "LARK_APP_ID": "你的AppID",
        "LARK_APP_SECRET": "你的AppSecret"
      }
    }
  }
}
```

## 使用建议

- **仅使用本地文件**：无需配置任何 MCP 服务器
- **使用飞书项目单**：需配置 `lark-prj-remote`
- **使用飞书云文档**：需配置 `lark-mcp-remote`
- **完整功能**：同时配置两个 MCP 服务器

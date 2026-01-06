---
description: 检查飞书MCP服务器配置状态，并提供配置指引。
---

# 检查飞书 MCP 配置

检查生成测试用例所需的飞书 MCP 服务器是否已正确配置。

## 所需 MCP 服务器

| 服务器名称 | 说明 | 必需 |
|-----------|------|------|
| `lark-prj-remote` | 飞书项目管理 MCP，用于读取单子信息 | 是 |
| `lark-mcp-remote` | 飞书云文档 MCP，用于读取技术文档 | 是 |

## 检查步骤

### 1. 查看当前 MCP 配置

请运行 `/mcp` 命令查看已配置的 MCP 服务器列表。

### 2. 验证服务器状态

在 MCP 列表中查找：
- `lark-prj-remote` - 飞书项目 MCP
- `lark-mcp-remote` - 飞书文档 MCP

如果这两个服务器都已列出且状态正常，则配置完成。

## 配置指南

如果缺少任一 MCP 服务器，请按以下步骤配置：

### 获取飞书应用凭证

1. 访问 [飞书开放平台](https://open.feishu.cn/)
2. 创建或选择一个应用
3. 获取 `App ID` 和 `App Secret`
4. 在应用权限中开启：
   - 项目管理相关权限（读取工作项）
   - 云文档相关权限（读取文档内容）

### 配置 lark-prj-remote（飞书项目 MCP）

**选项 A：使用命令行添加**

```bash
claude mcp add --transport stdio lark-prj-remote \
  --env LARK_APP_ID=cli_xxxxxxxxxx \
  --env LARK_APP_SECRET=xxxxxxxxxxxxxxxxxx \
  -- npx -y @anthropic/claude-code-mcp-lark-prj
```

**选项 B：编辑配置文件**

编辑 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "lark-prj-remote": {
      "command": "npx",
      "args": ["-y", "@anthropic/claude-code-mcp-lark-prj"],
      "env": {
        "LARK_APP_ID": "cli_xxxxxxxxxx",
        "LARK_APP_SECRET": "xxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### 配置 lark-mcp-remote（飞书文档 MCP）

**选项 A：使用命令行添加**

```bash
claude mcp add --transport stdio lark-mcp-remote \
  --env LARK_APP_ID=cli_xxxxxxxxxx \
  --env LARK_APP_SECRET=xxxxxxxxxxxxxxxxxx \
  -- npx -y @anthropic/claude-code-mcp-lark
```

**选项 B：编辑配置文件**

编辑 `~/.claude/settings.json`：

```json
{
  "mcpServers": {
    "lark-mcp-remote": {
      "command": "npx",
      "args": ["-y", "@anthropic/claude-code-mcp-lark"],
      "env": {
        "LARK_APP_ID": "cli_xxxxxxxxxx",
        "LARK_APP_SECRET": "xxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

### 完整配置示例

`~/.claude/settings.json` 完整示例：

```json
{
  "mcpServers": {
    "lark-prj-remote": {
      "command": "npx",
      "args": ["-y", "@anthropic/claude-code-mcp-lark-prj"],
      "env": {
        "LARK_APP_ID": "cli_xxxxxxxxxx",
        "LARK_APP_SECRET": "xxxxxxxxxxxxxxxxxx",
        "LARK_TENANT_ID": "optional_tenant_id"
      }
    },
    "lark-mcp-remote": {
      "command": "npx",
      "args": ["-y", "@anthropic/claude-code-mcp-lark"],
      "env": {
        "LARK_APP_ID": "cli_xxxxxxxxxx",
        "LARK_APP_SECRET": "xxxxxxxxxxxxxxxxxx"
      }
    }
  }
}
```

## 验证配置

配置完成后：

1. 重启 Claude Code
2. 运行 `/mcp` 确认服务器已列出
3. 运行 `/lark-testcase-generator:generate` 测试功能

## 常见问题

### Q: 提示 "MCP server not found"
A: 检查配置文件语法是否正确，确保 JSON 格式有效。

### Q: 提示 "Authentication failed"
A: 检查 `LARK_APP_ID` 和 `LARK_APP_SECRET` 是否正确。

### Q: 提示 "Permission denied"
A: 在飞书开放平台检查应用权限，确保已开启相关 API 权限。

### Q: 无法读取某些文档
A: 确保飞书应用已被添加为文档的协作者，或开启了文档的公开访问权限。

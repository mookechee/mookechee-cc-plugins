# Mookechee Plugin Marketplace

Claude Code 插件市场，提供飞书项目相关的效率工具。

## 可用插件

| 插件 | 描述 |
|------|------|
| [lark-testcase-generator](./plugins/lark-testcase-generator/) | 从飞书项目单子自动生成 OPML 格式的 XMind 测试用例 |

## 安装

### 添加 Marketplace

```bash
/plugin marketplace add mookechee/mookechee
```

### 安装插件

```bash
/plugin install lark-testcase-generator@mookechee
```

或使用交互式界面：

```bash
/plugin
```

在 **Discover** 标签页中浏览和安装。

### 本地开发模式

```bash
claude --plugin-dir /path/to/mookechee
```

## 目录结构

```
mookechee/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace 配置
├── plugins/
│   └── lark-testcase-generator/  # 测试用例生成插件
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       ├── skills/
│       └── hooks/
└── README.md
```

## 许可证

MIT

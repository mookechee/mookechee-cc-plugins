# CasePilot

Claude Code 插件，从需求文档自动生成 Markmap 思维导图测试用例。

## 快速开始

查看 [用户教程](./docs/getting-started.md) 了解完整的安装和使用流程。

## 可用插件

| 插件 | 描述 |
|------|------|
| [casepilot](./plugins/casepilot/) | 基于四阶段工作流的智能测试用例生成器，支持多输入源 |

## 安装

### 添加 Marketplace

```bash
/plugin marketplace add mookechee/casepilot
```

### 安装插件

```bash
/plugin install casepilot@casepilot
```

或使用交互式界面：

```bash
/plugin
```

在 **Discover** 标签页中浏览和安装。

### 本地开发模式

```bash
claude --plugin-dir /path/to/casepilot
```

## 输出路径

所有测试用例文件统一输出到：

```
~/Testcase/opml/
```

文件命名格式：`{工作项名称}_测试用例_{时间戳}.md`

时间戳格式：`YYYYMMDD_HHmmss`

如果目录不存在，会自动创建。

## 目录结构

```
casepilot/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace 配置
├── plugins/
│   └── casepilot/                # 四阶段智能测试用例生成器
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       ├── skills/
│       └── hooks/
└── README.md
```

## 许可证

MIT

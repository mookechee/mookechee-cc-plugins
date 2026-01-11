# Mookechee CC Plugins

Claude Code 插件市场，提供飞书项目相关的效率工具。

## 可用插件

| 插件 | 描述 |
|------|------|
| [lark-testcase-generator](./plugins/lark-testcase-generator/) | 从飞书项目单子自动生成 OPML 格式的 XMind 测试用例 |
| [testflow-generator](./plugins/testflow-generator/) | 基于四阶段工作流的智能测试用例生成器，支持多输入源 |

### 插件对比

| 特性 | lark-testcase-generator | testflow-generator |
|------|-------------------------|-------------------|
| 输入源 | 仅飞书项目单 | 飞书项目单 + 云文档 + 本地文件 |
| 生成流程 | 单阶段 | 四阶段渐进式 |
| 需求分析 | 无 | 有（需求点拆分） |
| 测试点生成 | 无 | 有（二八法则） |
| 验收标准覆盖 | 有 | 有（强化） |

## 安装

### 添加 Marketplace

```bash
/plugin marketplace add mookechee/mookechee-cc-plugins
```

### 安装插件

```bash
# 安装 lark-testcase-generator
/plugin install lark-testcase-generator@mookechee-cc-plugins

# 安装 testflow-generator
/plugin install testflow-generator@mookechee-cc-plugins
```

或使用交互式界面：

```bash
/plugin
```

在 **Discover** 标签页中浏览和安装。

### 本地开发模式

```bash
claude --plugin-dir /path/to/mookechee-cc-plugins
```

## 输出路径

所有测试用例文件统一输出到：

```
~/Testcase/opml/
```

| 插件 | 文件命名格式 |
|------|-------------|
| lark-testcase-generator | `{项目名}-testcase_{时间戳}.opml` |
| testflow-generator | `{工作项名称}_测试用例_{时间戳}.opml` |

时间戳格式：`YYYYMMDD_HHmmss`

如果目录不存在，会自动创建。

## 目录结构

```
mookechee-cc-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace 配置
├── plugins/
│   ├── lark-testcase-generator/  # 飞书项目测试用例生成器
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   ├── skills/
│   │   └── hooks/
│   └── testflow-generator/       # 四阶段智能测试用例生成器
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       ├── skills/
│       └── hooks/
└── README.md
```

## 许可证

MIT

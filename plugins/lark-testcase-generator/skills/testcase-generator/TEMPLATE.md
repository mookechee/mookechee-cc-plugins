# OPML 测试用例模板

## 基础模板

```xml
<?xml version="1.0" encoding="UTF-8"?>
<opml version="2.0">
  <head>
    <title>{项目名称}测试用例</title>
    <dateCreated>{日期}</dateCreated>
    <expansionState>0,1,2,3,4,5,6,7,8</expansionState>
  </head>
  <body>
    <outline text="{项目名称}测试用例">
      <!-- 测试模块 -->
      <outline text="{模块名称}">
        <!-- 测试用例：链式结构 -->
        <outline text="{用例名称}">
          <outline text="{前置条件}">
            <outline text="{执行步骤}">
              <outline text="{预期结果}">
                <outline text="{优先级}"/>
              </outline>
            </outline>
          </outline>
        </outline>
      </outline>
    </outline>
  </body>
</opml>
```

## 常见测试模块模板

### 编译构建测试

```xml
<outline text="编译构建测试">
  <outline text="{目标平台}编译成功验证">
    <outline text="已安装{工具链}和{目标}">
      <outline text="在{目录}执行 {编译命令}">
        <outline text="编译成功，无错误输出，生成目标产物">
          <outline text="P0"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 会话/连接管理测试

```xml
<outline text="会话管理测试-{阶段}">
  <outline text="{请求类型}请求正常处理">
    <outline text="{组件}处于{状态}状态">
      <outline text="发送{请求类型}请求（{参数}）">
        <outline text="返回{响应类型}响应，{验证点}，状态变为{新状态}">
          <outline text="P0"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 心跳/超时测试

```xml
<outline text="心跳超时检测">
  <outline text="{组件}处于Active状态，{参数}={值}">
    <outline text="超过{时间}未发送心跳，调用{检测方法}">
      <outline text="{计数器}增加，状态{变化描述}">
        <outline text="P0"/>
      </outline>
    </outline>
  </outline>
</outline>
```

### 接口/Handler 测试

```xml
<outline text="{Handler}测试">
  <outline text="{方法名}方法-{场景}">
    <outline text="{Handler}已实现，{资源条件}">
      <outline text="调用{方法名}({参数})">
        <outline text="返回{返回值}，{验证点}">
          <outline text="P1"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 错误处理测试

```xml
<outline text="错误处理测试">
  <outline text="{错误类型}错误-{触发条件}">
    <outline text="{组件}正常运行">
      <outline text="{触发错误的操作}">
        <outline text="返回{错误类型}错误">
          <outline text="P1"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 配置测试

```xml
<outline text="{配置类}配置测试">
  <outline text="{配置项}配置-{场景}">
    <outline text="创建{配置类}实例">
      <outline text="设置{配置项}为{值}">
        <outline text="配置成功，{配置项}值为{值}{说明}">
          <outline text="P1"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 集成测试

```xml
<outline text="集成测试">
  <outline text="{集成场景}">
    <outline text="{组件A}已完成，{组件B}已添加依赖">
      <outline text="执行 {集成命令/操作}">
        <outline text="{集成成功验证点}">
          <outline text="P0"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 端到端测试

```xml
<outline text="端到端测试">
  <outline text="{端到端场景}">
    <outline text="{测试客户端}与{设备/服务}建立连接">
      <outline text="执行{完整流程}">
        <outline text="所有步骤正确执行，{验证点}">
          <outline text="P0"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 状态机测试

```xml
<outline text="{状态上下文}状态机测试">
  <outline text="状态转换-{起始状态}到{目标状态}">
    <outline text="{上下文}处于{起始状态}状态">
      <outline text="{触发条件/事件}">
        <outline text="状态变为{目标状态}，{附加验证}">
          <outline text="P0"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

### 资源限制测试

```xml
<outline text="内存与资源限制测试">
  <outline text="{限制项}验证">
    <outline text="{组件}配置{限制项}={限制值}">
      <outline text="尝试{超出限制的操作}">
        <outline text="{操作}失败，返回{错误类型}错误">
          <outline text="P1"/>
        </outline>
      </outline>
    </outline>
  </outline>
</outline>
```

## 优先级分配指南

### P0 场景（必须测试）

- 核心业务正向流程
- 编译/构建验证
- 关键状态转换
- 主要 API 正常调用
- 端到端关键路径

### P1 场景（应该测试）

- 配置参数验证
- 异常/错误处理
- 边界条件
- 次要 API 调用
- 状态恢复

### P2 场景（可选测试）

- 辅助功能
- 日志/调试信息
- 性能优化验证
- 可选参数

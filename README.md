<!--
 * @Author: LetMeFly
 * @Date: 2025-01-26 12:24:51
 * @LastEditors: LetMeFly.xyz
 * @LastEditTime: 2025-01-26 12:36:32
-->
# secret-monitor

一个简单的密钥监测Action脚本，在commit时或pr时检测是否包含密钥

## 使用方法

1. 在仓库Settings > Secrets中配置密钥：
   - 名称格式：`LetSecret_*`（如`LetSecret_DB_PWD`）
   - 值类型：
     - 文本密码：直接填写
     - 正则表达式：用`/`包裹（如`/\d{3}-\d{4}/`）

2. 添加工作流文件：

```yaml
steps:
  - uses: LetMeFly666/secret-monitor@v1
    env:
      LetSecret_API_KEY: "your_actual_secret"
      LetSecret_IP_REGEX: "/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/"
```

## 自定义配置

| 参数          | 默认值   | 说明               |
|---------------|----------|--------------------|
| custom_prefix | LetSecret | 环境变量前缀       |

## End

这个方案实现了：

1. **开箱即用**：使用者只需配置环境变量即可启用
2. **零成本集成**：无需维护服务器，完全基于GitHub生态
3. **双重检测模式**：同时支持明文和正则表达式检测
4. **精准定位**：在PR中直接标记问题位置，降低修复成本
<!--
 * @Author: LetMeFly
 * @Date: 2025-01-26 12:24:51
 * @LastEditors: LetMeFly.xyz
 * @LastEditTime: 2025-01-27 07:27:54
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

## 开发日志

### v0.1尝试用DeepSeek写

Debug的时间都够自己写了

### v0.2分功能实现

**所需功能**

- [x] 在action中评论（[Code](https://github.com/LetMeFly666/secret-monitor/blob/4281d9a07bd253fca65731369c9748affaa33074/.github/workflows/test.yml#L2-L23)）
- [x] 读取某次PR的所有commit、向PR中新增commit
- [ ] 某commit所有文件检测是否存在密钥，并保存结果


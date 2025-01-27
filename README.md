<!--
 * @Author: LetMeFly
 * @Date: 2025-01-26 12:24:51
 * @LastEditors: LetMeFly.xyz
 * @LastEditTime: 2025-01-27 21:31:41
-->
# secret-monitor

一个简单的密钥监测Action脚本，在commit时或pr时检测是否包含密钥

## 使用方法

1. 在仓库Settings > Secrets中配置密钥：
   - 名称格式：`LetSecret_*`（如`LetSecret_DB_PWD`）
   - 值类型：
     - 文本密码：直接填写

2. 添加工作流文件：

```yaml
steps:
  - uses: LetMeFly666/secret-monitor@v1
    env:
      LetSecret_API_KEY: "your_actual_secret"
```

## 触发条件

1. 新增commit(只会检测最后一次commit)中包含秘密信息，Action直接运行失败
2. 新增PR/PR关闭后重启时，检测PR中所有commit，若包含秘密信息，在PR中评论所有秘密信息所在位置并且Action运行失败
3. 往开启的PR中新增commit时，检测新增commit和所有commit。
    + 若新增commit不包含秘密信息：
       + 若旧commit中仍包含秘密信息，则Action运行失败
       + 否则Action运行成功
    + 否则（新commit包含秘密信息）：评论新增commit中秘密信息所在位置并且Action运行失败

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
- [x] 读取某次PR的所有commit、向PR中新增commit（[Code](https://github.com/LetMeFly666/secret-monitor/blob/a83dca97bb4aa694ee05153e00eda00ac8f31faf/.github/workflows/test.yml#L2-L38)）
- [x] 某commit所有文件检测是否存在密钥，并保存结果（[Code](https://github.com/LetMeFly666/secret-monitor/blob/e56eea1a103e640e35531f85e0490ab3c723fd1f/.github/workflows/test.yml#L1-L17)）

决定暂不支持正则表达式

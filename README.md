<!--
 * @Author: LetMeFly
 * @Date: 2025-01-26 12:24:51
 * @LastEditors: LetMeFly.xyz
 * @LastEditTime: 2025-01-30 10:00:19
-->
# secret-monitor

一个简单的密钥监测Action脚本，在commit时或pr时检测是否包含密钥/密码

## 使用方法

```yaml
name: 'Test action'
on:
  push:
    branches:
      - '**'
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  scan:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read
    steps:
      - name: run the action
        uses: LetMeFly666/secret-monitor@master
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
        env:
          LETSECRET_SECRETS: ${{ secrets.LETSECRET_TEST_VALUEIS1TO9 }}  # 这里可以设置为环境变量
```

## 触发条件/行为表现

1. 新增commit时，检测最后一次commit中是否包含秘密信息
    + 若包含：Action直接运行失败
    + 否则（不包含密钥信息）：Action运行成功
2. 新增PR/PR关闭后重启时，检测PR中所有commit，若包含秘密信息，在PR中评论所有秘密信息所在位置并且Action运行失败
3. 往开启的PR中新增commit时，检测新增commit和所有commit。
    + 若新增commit不包含秘密信息：
        + 若旧commit中仍包含秘密信息，则评论提醒删除旧commit信息并且Action运行失败
        + 否则Action运行成功
    + 否则（新commit包含秘密信息）：评论新增commit中秘密信息所在位置并且Action运行失败

测试仓库：[secret-monitor-tester](https://github.com/LetMeFly666/secret-monitor-tester)

## 自定义配置

| 参数          | 默认值   | 说明               |
|---------------|----------|--------------------|
| custom_prefix | LetSecret | 环境变量前缀       |

暂不支持修改

## 开发日志

### v0.1尝试用DeepSeek写

Debug的时间都够自己写了

### v0.2分功能实现

**所需功能**

- [x] 在action中评论（[Code](https://github.com/LetMeFly666/secret-monitor/blob/4281d9a07bd253fca65731369c9748affaa33074/.github/workflows/test.yml#L2-L23)）
- [x] 读取某次PR的所有commit、向PR中新增commit（[Code](https://github.com/LetMeFly666/secret-monitor/blob/a83dca97bb4aa694ee05153e00eda00ac8f31faf/.github/workflows/test.yml#L2-L38)）
- [x] 某commit所有文件检测是否存在密钥，并保存结果（[Code](https://github.com/LetMeFly666/secret-monitor/blob/e56eea1a103e640e35531f85e0490ab3c723fd1f/.github/workflows/test.yml#L1-L17)）

决定暂不支持正则表达式

### v0.3 action.yml化，以供其他仓库调用

- [x] ~~确保commit_hash不会出现在action的log中，否则细心的人可能据此访问“历史悬空commit”~~  还是手动删action log吧
- [ ] 自定义前缀定义了但是未使用
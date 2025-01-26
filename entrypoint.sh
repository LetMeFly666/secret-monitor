###
 # @Author: LetMeFly
 # @Date: 2025-01-26 12:25:39
 # @LastEditors: LetMeFly.xyz
 # @LastEditTime: 2025-01-26 12:26:41
### 
#!/bin/bash

# 获取环境变量前缀（默认为LetSecret）
PREFIX=${CUSTOM_PREFIX:-LetSecret}

# 收集所有符合前缀的密钥/正则
SECRET_VARS=$(env | grep "^${PREFIX}" | cut -d= -f1)

# 临时存储检测结果
FOUND_SECRETS=""

# 获取差异文件内容
if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
  DIFF_CONTENT=$(git diff --unified=0 origin/$GITHUB_BASE_REF..HEAD)
else
  DIFF_CONTENT=$(git diff HEAD^ HEAD)
fi

# 逐个检查密钥
for var_name in $SECRET_VARS; do
  secret_value="${!var_name}"
  
  # 判断是否是正则表达式（以/开头和结尾）
  if [[ "$secret_value" =~ ^/.*/$ ]]; then
    pattern=$(echo "$secret_value" | sed 's:^/::;s:/$::')
    if echo "$DIFF_CONTENT" | grep -P -- "$pattern"; then
      FOUND_SECRETS+="\n- ${var_name} (正则: ${secret_value})"
    fi
  else
    if echo "$DIFF_CONTENT" | grep -F -- "$secret_value"; then
      FOUND_SECRETS+="\n- ${var_name}"
    fi
  fi
done

# 处理检测结果
if [ -n "$FOUND_SECRETS" ]; then
  echo "::error::发现敏感信息！请检查以下内容：${FOUND_SECRETS}"
  
  # 如果是PR，添加评论
  if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    COMMENT="⚠️ **安全警报** ⚠️\n检测到以下敏感信息：${FOUND_SECRETS}\n请立即删除并重置相关凭证！"
    curl -s -X POST \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
      -d "{\"body\":\"$COMMENT\"}"
  fi
  
  exit 1
fi

echo "✅ 未检测到敏感信息"
exit 0
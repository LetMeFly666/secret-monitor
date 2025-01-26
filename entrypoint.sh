###
 # @Author: LetMeFly
 # @Date: 2025-01-26 12:25:39
 # @LastEditors: LetMeFly.xyz
 # @LastEditTime: 2025-01-26 17:56:44
### 
#!/bin/bash

# 获取环境变量前缀（默认为LetSecret）
PREFIX=${CUSTOM_PREFIX:-LetSecret}

# 收集所有符合前缀的密钥/正则
SECRET_VARS=$(env | grep "^${PREFIX}" | cut -d= -f1)
echo "🔍 检测到密钥变量: $SECRET_VARS"

# 临时存储检测结果
FOUND_SECRETS=""
LEAK_DETECTED=false  # 新增泄漏标记

# 获取仓库全量文件（排除.git目录）
FILE_LIST=$(find . -type f -not -path './.git/*')
echo "📂 待扫描文件数: $(echo "$FILE_LIST" | wc -l)"

# 配置排除路径（可扩展）
EXCLUDE_PATHS=(
  "*.png"
  "*.jpg"
  "*.pdf"
  "*.zip"
  "./.git/*"
  "./node_modules/*"
)

# 遍历所有文件
while IFS= read -r file; do
  # 跳过二进制文件和排除路径
  if file --mime-encoding "$file" | grep -q binary; then
    echo "⏭️ 跳过二进制文件: $file"
    continue
  fi
  
  skip=false
  for pattern in "${EXCLUDE_PATHS[@]}"; do
    if [[ "$file" == $pattern ]]; then
      echo "⏭️ 跳过排除文件: $file"
      skip=true
      break
    fi
  done
  [[ $skip == true ]] && continue

  # 读取文件内容
  content=$(cat "$file")
  
  # 检查每个密钥
  for var_name in $SECRET_VARS; do
    secret_value="${!var_name}"
    
    # 正则匹配模式
    if [[ "$secret_value" =~ ^/.*/$ ]]; then
      pattern=$(echo "$secret_value" | sed 's:^/::;s:/$::')
      if echo "$content" | grep -Pq -- "$pattern"; then
        FOUND_SECRETS+="\n- 文件: $file\n  类型: ${var_name}\n  匹配模式: ${secret_value}"
        LEAK_DETECTED=true
      fi
    
    # 文本匹配模式
    else
      if echo "$content" | grep -Fq -- "$secret_value"; then
        FOUND_SECRETS+="\n- 文件: $file\n  类型: ${var_name}\n  匹配内容: ${secret_value}"
        LEAK_DETECTED=true
      fi
    fi
  done

done <<< "$FILE_LIST"

# 处理检测结果
if $LEAK_DETECTED; then
  echo "🚨 发现敏感信息！详细内容："
  echo -e "$FOUND_SECRETS"
  
  # 将结果写入文件供后续步骤使用
  echo -e "$FOUND_SECRETS" > scan_result.txt
  
  # PR评论信息（不再直接退出）
  if [ "$GITHUB_EVENT_NAME" = "pull_request" ]; then
    PR_NUMBER=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
    COMMENT="⚠️ **全量扫描安全警报** ⚠️\n检测到以下敏感信息：\n${FOUND_SECRETS}"
    echo "$COMMENT" > comment_body.txt
  fi
else
  echo "✅ 全量扫描完成，未检测到敏感信息"
  echo "" > scan_result.txt
fi
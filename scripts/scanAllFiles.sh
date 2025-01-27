###
 # @Author: LetMeFly
 # @Date: 2025-01-27 14:50:34
 # @LastEditors: LetMeFly.xyz
 # @LastEditTime: 2025-01-27 15:57:31
### 
###
 # 扫描一个commit hash的所有文件判断是否存在敏感信息
 # Input: 
 #   - commit_sha $COMMIT_SHA
 #   - 【可选】密钥前缀 $SECRET_PREFIX
 # Output: /tmp/scan_result.txt（扫描结果）
###

# ----------------------------- 检查必要环境变量 -----------------------------
if [[ "$(uname -o)" == "Msys" ]]; then  # Windows
    export MSYS_NO_PATHCONV=1  # 否则的话，Git bash在Windows上会将/api转为F:/xxx/api
fi
REQUIRED_VARS=("COMMIT_SHA")
missing_vars=0
for var in ${REQUIRED_VARS[@]}; do
    if [[ -z "${!var}" ]]; then
        echo "❌ 缺少必要环境变量: $var"
        missing_vars=1
    fi
done
if [[ $missing_vars -eq 1 ]]; then
    exit 1
fi
echo "✅ 所有必要环境变量已设置"

# ------------- 收集所有符合前缀的密钥/正则 -------------
PREFIX=${SECRET_PREFIX:-LetSecret}
has_secret=false
SECRET_VARS=$(env | grep "^${PREFIX}" | cut -d= -f1)
for var in ${SECRET_VARS[@]}; do
    echo "🔍 检测到密钥变量: $var"
    has_secret=true
done
if ! $has_secret; then
    echo "❗ 没有待检测内容"
    exit 0
fi

# ------------- 获取仓库全量文件 -------------
git checkout $COMMIT_SHA
FILE_LIST=$(find . -type f -not -path './.git/*')
echo "📂 待扫描文件数: $(echo "$FILE_LIST" | wc -l)"
EXCLUDE_PATHS=(
    "*.png"
    "*.jpg"
    "*.pdf"
    "*.zip"
    "./.git/*"
    "./node_modules/*"
)

# ------------- 遍历所有文件 -------------
LEAK_DETECTED=false
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
        # 正则
        if [[ "$secet_value" =~ ^/.*/$ ]]; then
            pattern=$(echo "$secret_value" | sed 's:^/::;s:/$::')
            if echo "$content" | grep -Pq -- "$pattern"; then
                FOUND_SECRETS+="\n- 文件: $file\n  类型: ${var_name}\n  匹配模式: ${secret_value}"
                LEAK_DETECTED=true
            fi
        # 文本
        else
            if echo "$content" | grep -Fq -- "$secret_value"; then
                FOUND_SECRETS+="\n- 文件: $file\n  类型: ${var_name}\n  匹配内容: ${secret_value}"
                LEAK_DETECTED=true
            fi
        fi
    done
done <<< "$FILE_LIST"

# ------------- 处理检测结果 -------------
if $LEAK_DETECTED; then
  echo "🚨 发现敏感信息！详细内容："
  echo -e "$FOUND_SECRETS"
  # 将结果写入文件供后续步骤使用
  echo -e "$FOUND_SECRETS" > /tmp/scan_result.txt
  cat /tmp/scan_result.txt
else
  echo "✅ 全量扫描完成，未检测到敏感信息"
  echo "" > /tmp/scan_result.txt
fi
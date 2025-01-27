###
 # @Author: LetMeFly
 # @Date: 2025-01-27 17:59:42
 # @LastEditors: LetMeFly.xyz
 # @LastEditTime: 2025-01-27 18:07:44
### 
###
 # Input: 仓库名$REPO_FULL_NAME（例如LetMeFly666/secret-monitor）
 #
 # 依据/tmp/scan_result/文件夹下的内容生成一个生成一个commentBody
 # 在/tmp/scan_result/文件夹下，有很多以commit hash命名的子文件夹。子文件夹中有可能会有一些文件。
 # 如果有，则文件内容有两行，第一行是文件路径(例如./test/withPlainSecret/20250125-1258-0000，注意可能要去掉开头的.)，第二行是一个数字，代表行号。
 #
 # 生成的commentBody，格式内容如下：
 #
 # ```
 # 💥机密泄露
 #
 # 1. https://github.com/LetMeFly666/secret-monitor/blob/e56eea1a103e640e35531f85e0490ab3c723fd1f/test/withPlainSecret/20250125-1258-0000 #L14
 # 2. https://.......
 # ```
###

# ----------------------------- 检查必要环境变量 -----------------------------
REQUIRED_VARS=("REPO_FULL_NAME")
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

# 定义结果目录
RESULT_DIR="/tmp/scan_result"

# 初始化 commentBody
commentBody="💥机密泄露\n\n"

# 遍历所有 commit hash 子文件夹
for commit_dir in "$RESULT_DIR"/*; do
    # 检查是否是目录
    if [[ -d "$commit_dir" ]]; then
        commit_hash=$(basename "$commit_dir")
        
        # 遍历子文件夹中的文件
        for result_file in "$commit_dir"/*; do
            if [[ -f "$result_file" ]]; then
                # 读取文件内容
                file_path=$(sed -n '1p' "$result_file" | sed 's/^\.//')  # 去掉开头的 .
                line_number=$(sed -n '2p' "$result_file")
                
                # 生成 GitHub 链接
                github_link="https://github.com/$REPO_FULL_NAME/blob/$commit_hash$file_path#L$line_number"
                
                # 添加到 commentBody
                commentBody+="1. $github_link\n"
            fi
        done
    fi
done

# 将 commentBody 保存到文件
echo -e "$commentBody" > /tmp/comment_body.txt
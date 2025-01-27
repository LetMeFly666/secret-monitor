###
 # @Author: LetMeFly
 # @Date: 2025-01-27 10:36:25
 # @LastEditors: LetMeFly.xyz
 # @LastEditTime: 2025-01-27 10:42:59
### 
###
 # 获取某PR的所有commit Hash
 # 前提: 环境变量$GITHUB_TOKEN
 # Input: 
 #   - 触发这次流程前的commit_sha $BEFORE_SHA
 #   - 触发这次流程时的commit_sha $AFTER_SHA
 #   - 仓库名$REPO_FULL_NAME（例如LetMeFly666/secret-monitor）
 # Output: /tmp/pr_commits_new.txt（每行一个commit Hash）
###

# ----------------------------- 检查必要环境变量 -----------------------------
if [[ "$(uname -o)" == "Msys" ]]; then  # Windows
    REQUIRED_VARS=("BEFORE_SHA" "AFTER_SHA" "REPO_FULL_NAME")
    export MSYS_NO_PATHCONV=1  # 否则的话，Git bash在Windows上会将/api转为F:/xxx/api
else
    REQUIRED_VARS=("GITHUB_TOKEN" "BEFORE_SHA" "AFTER_SHA" "REPO_FULL_NAME")
fi
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


# ----------------------------- 获取commit记录 -----------------------------
GH_APIURI="/repos/$REPO_FULL_NAME/compare/$BEFORE_SHA...$AFTER_SHA"
echo "GH_APIURI: $GH_APIURI"
RESPONSE=$(gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "$GH_APIURI")
if [[ $? -ne 0 ]]; then
    echo "❌ 获取PR提交记录失败"
    exit 1
fi

# ----------------------------- 将结果写入文件 -----------------------------
echo "$RESPONSE" | jq -r '.commits[].sha' > /tmp/pr_commits_new.txt
echo "***BEGIN CAT***"
cat /tmp/pr_commits_new.txt
echo "***END CAT***"
###
 # @Author: LetMeFly
 # @Date: 2025-01-27 09:32:48
 # @LastEditors: LetMeFly.xyz
 # @LastEditTime: 2025-01-27 10:39:35
### 
###
 # 获取某PR的所有commit Hash
 # 前提: 环境变量$GITHUB_TOKEN
 # Input: 
 #   - PR编号$PR_NUMBER
 #   - 仓库名$REPO_FULL_NAME（例如LetMeFly666/secret-monitor）
 # Output: /tmp/pr_commits_all.txt（每行一个commit Hash）
###

# ----------------------------- 检查必要环境变量 -----------------------------
if [[ "$(uname -o)" == "Msys" ]]; then  # Windows
    REQUIRED_VARS=("PR_NUMBER" "REPO_FULL_NAME")
    export MSYS_NO_PATHCONV=1  # 否则的话，Git bash在Windows上会将/api转为F:/xxx/api
else
    REQUIRED_VARS=("GITHUB_TOKEN" "PR_NUMBER" "REPO_FULL_NAME")
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
# https://docs.github.com/zh/rest/pulls/pulls?apiVersion=2022-11-28#list-commits-on-a-pull-request
GH_APIURI="/repos/$REPO_FULL_NAME/pulls/$PR_NUMBER/commits"
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
echo "$RESPONSE" | jq -r '.[].sha' > /tmp/pr_commits_all.txt
echo "***BEGIN CAT***"
cat /tmp/pr_commits_all.txt
echo "***END CAT***"
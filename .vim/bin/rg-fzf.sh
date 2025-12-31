#!/usr/bin/env bash

# 1. 禁用通配符展开 (防止 *.cc 被 Shell 展开)
set -f

# 2. 获取输入并清洗引号
# 这里的 tr -d "'\"" 是为了去掉 Vim 传过来的多余引号
INPUT_STR=$(printf '%s' "$*" | tr -d "'\"")

# 3. 门卫检查 (小于2个字符不搜索)
CLEAN_CONTENT=$(echo "$INPUT_STR" | tr -d ' ')
if [ ${#CLEAN_CONTENT} -lt 2 ]; then
    exit 0
fi

# 4. 转义处理
# 将 \ 替换为 \\，防止 eval 吃掉反斜杠
ESCAPED_STR=$(echo "$INPUT_STR" | sed 's/\\/\\\\/g')

# 5. 定义 RG 命令
RG_CMD="rg --column --line-number --no-heading --color=always --smart-case --max-columns=200 --glob !.git/* --glob !node_modules/* --glob !out/* --glob !mtout/*"

# 6. 执行命令
eval "$RG_CMD $ESCAPED_STR" 2> /dev/null || true

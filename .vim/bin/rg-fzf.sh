#!/usr/bin/env bash

# 1. 禁用通配符展开
set -f

# 2. 获取输入
# 【关键修改】删除了 tr -d "'\""，保留用户输入的引号
INPUT_STR="$*"

# 3. 门卫检查
CLEAN_CONTENT=$(echo "$INPUT_STR" | tr -d ' ')
if [ ${#CLEAN_CONTENT} -lt 2 ]; then
    exit 0
fi

# 4. 转义处理
ESCAPED_STR=$(echo "$INPUT_STR" | sed 's/\\/\\\\/g')

# 5. 定义 RG 命令
RG_CMD="rg --column --line-number --no-heading --color=always --smart-case --max-columns=200 --glob !.git/* --glob !node_modules/* --glob !out/* --glob !mtout/*"

# 6. 执行命令
eval "$RG_CMD $ESCAPED_STR" 2> /dev/null || true

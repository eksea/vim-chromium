#!/usr/bin/env bash

# 接收所有参数（保留空格）
query="$*"

# 空查询检查
if [ -z "$query" ]; then
  exit 0
fi

# 基础命令
RG_BASE="rg --column --line-number --no-heading --color=always --smart-case --hidden"
RG_EXCLUDE="--glob '!.git/*' --glob '!out/*' --glob '!mtout/*' --glob '!node_modules/*'"

# 检测 -F
FIXED_STRING=""
if [[ "$query" =~ (^|[[:space:]])-F([[:space:]]|$) ]]; then
  FIXED_STRING="-F"
  query=$(echo "$query" | sed -E 's/(^|[[:space:]])-F([[:space:]]|$)/ /g')
fi

# 检测 -g
GLOB_PATTERN=""
if [[ "$query" =~ -g[[:space:]]+([^[:space:]]+) ]]; then
  GLOB_PATTERN="${BASH_REMATCH[1]}"
  query=$(echo "$query" | sed -E "s/-g[[:space:]]+[^[:space:]]+//g")
fi

# 清理空格
query=$(echo "$query" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

# 再次检查
if [ -z "$query" ]; then
  exit 0
fi

# 执行搜索
if [ -n "$GLOB_PATTERN" ]; then
  eval "$RG_BASE $FIXED_STRING $RG_EXCLUDE --glob '$GLOB_PATTERN' -- \"\$query\""
else
  eval "$RG_BASE $FIXED_STRING $RG_EXCLUDE -- \"\$query\""
fi

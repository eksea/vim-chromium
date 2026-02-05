#!/usr/bin/env bash

# 接收所有输入
input="$*"

# 如果输入为空，直接退出
if [ -z "$input" ]; then
  exit 0
fi

# 最小字符数检查（至少 3 个字符）
if [ ${#input} -lt 3 ]; then
  exit 0
fi

# 基础必需参数（FZF 需要的格式）
RG_BASE="rg --column --line-number --no-heading --color=always"

# 默认参数（当用户没有提供对应参数时使用）
RG_DEFAULT="--smart-case --hidden"

# 排除目录（始终生效）
RG_EXCLUDE="--glob '!.git/*' --glob '!out/*' --glob '!mtout/*' --glob '!node_modules/*'"

# 检查用户是否提供了自定义参数（以 - 或 -- 开头）
if [[ "$input" =~ (^|[[:space:]])(-[^[:space:]]+) ]]; then
  # 用户提供了参数，直接透传所有内容给 rg
  eval "$RG_BASE $RG_EXCLUDE $input"
else
  # 用户只提供了搜索词，使用默认配置
  eval "$RG_BASE $RG_DEFAULT $RG_EXCLUDE -- \"\$input\""
fi

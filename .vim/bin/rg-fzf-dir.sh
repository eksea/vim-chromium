#!/usr/bin/env bash

# 用法: rg-fzf-dir.sh <search_dir> <query>
# 在指定目录下进行 ripgrep 搜索

search_dir="$1"
shift
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

# 默认参数
RG_DEFAULT="--smart-case --hidden"

# 排除目录（始终生效）
RG_EXCLUDE="--glob '!.git/*' --glob '!out/*' --glob '!mtout/*' --glob '!node_modules/*'"

# 检查用户是否提供了自定义参数（以 - 或 -- 开头）
if [[ "$input" =~ (^|[[:space:]])(-[^[:space:]]+) ]]; then
  eval "$RG_BASE $RG_EXCLUDE $input -- \"$search_dir\""
else
  eval "$RG_BASE $RG_DEFAULT $RG_EXCLUDE -- \"\$input\" \"$search_dir\""
fi

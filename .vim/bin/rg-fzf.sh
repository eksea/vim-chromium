#!/usr/bin/env bash

# 获取输入参数
query="$1"

# 1. 定义基础 RG 命令
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/*' --glob '!out/*' --glob '!mtout/*' --glob '!node_modules/*'"

# 2. 检测并处理 -F 参数 (固定字符串/精确匹配模式)
# 如果输入中包含 -F，则启用 rg 的 -F 选项，并从查询中移除 -F
if [[ "$query" =~ -F ]]; then
  RG_PREFIX="$RG_PREFIX -F"
  # 移除 -F
  query=${query//-F/}
fi

# 3. 检测并处理 -g 参数 (文件过滤)
if [[ "$query" =~ -g[[:space:]]+([^[:space:]]+) ]]; then
  glob="${BASH_REMATCH[1]}"
  
  # 移除 -g *.cc
  search_term=${query//-g $glob/}
  search_term=${search_term//-g$glob/}
  
  # 去除首尾空格
  search_term=$(echo "$search_term" | xargs)

  # 执行搜索
  eval "$RG_PREFIX --glob '$glob' '$search_term'"
else
  # 去除可能残留的首尾空格
  query=$(echo "$query" | xargs)
  
  # 执行普通搜索
  eval "$RG_PREFIX '$query'"
fi

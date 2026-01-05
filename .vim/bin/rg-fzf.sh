#!/bin/bash

# 获取查询字符串
query="$1"

# 如果查询为空或少于2个字符，返回空
if [ -z "$query" ] || [ ${#query} -lt 3 ]; then
  exit 0
fi

# 检测是否包含 -g 参数（文件名过滤）
if [[ "$query" =~ ^-g[[:space:]]+ ]]; then
  # 提取 -g 参数和搜索关键词
  # 示例输入: "-g *.cpp keyword"
  
  # 提取 -g 后的第一个参数（文件模式）
  glob_pattern=$(echo "$query" | sed -n 's/^-g[[:space:]]\+$[^[:space:]]\+$.*/\1/p')
  
  # 提取剩余的搜索关键词
  search_term=$(echo "$query" | sed 's/^-g[[:space:]]\+[^[:space:]]\+[[:space:]]\+//')
  
  # 如果搜索词为空或少于2字符，只返回匹配的文件列表
  if [ -z "$search_term" ] || [ ${#search_term} -lt 2 ]; then
    rg --files --glob "$glob_pattern" 2>/dev/null | \
      awk '{print $0":1:1:"}'
    exit 0
  fi
  
  # 在指定文件类型中搜索
  rg --column --line-number --no-heading --color=always \
     --smart-case --max-columns=200 \
     --hidden \
     --glob "$glob_pattern" \
     --glob '!.git/*' \
     --glob '!out/*' \
     --glob '!mtout/*' \
     --glob '!node_modules/*' \
     "$search_term" 2>/dev/null
else
  # 普通搜索（无 -g 参数）
  rg --column --line-number --no-heading --color=always \
     --smart-case --max-columns=200 \
     --hidden \
     --glob '!.git/*' \
     --glob '!out/*' \
     --glob '!mtout/*' \
     --glob '!node_modules/*' \
     "$query" 2>/dev/null
fi

#!/usr/bin/env bash

# 获取输入参数
query="$1"

# 1. 定义基础 RG 命令
# --smart-case: 智能大小写
# --hidden: 搜索隐藏文件
# --glob: 排除 .git, out, node_modules 等目录
RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case --hidden --glob '!.git/*' --glob '!out/*' --glob '!mtout/*' --glob '!node_modules/*'"

# 2. 检测是否包含 -g 参数
# 正则解释：匹配 -g 后跟空格，然后捕获非空格的字符串(即 glob 模式)
if [[ "$query" =~ -g[[:space:]]+([^[:space:]]+) ]]; then
  # 提取 glob 模式 (例如 *.cc)
  glob="${BASH_REMATCH[1]}"

  # 从查询字符串中移除 "-g *.cc" 部分
  # 使用 Bash 内置替换，避免 sed 处理 * 号时的转义问题
  search_term=${query//-g $glob/}
  
  # 如果用户少打了一个空格 (如 -g*.cc)，也尝试移除
  search_term=${search_term//-g$glob/}

  # 去除首尾多余的空格 (使用 xargs trim)
  search_term=$(echo "$search_term" | xargs)

  # 3. 执行带 glob 的搜索
  # 注意：这里使用 eval 是为了正确处理引号，防止 glob 被 shell 提前展开
  # 我们给 $glob 加上单引号，确保传给 rg 的是字面量 *.cc
  eval "$RG_PREFIX --glob '$glob' '$search_term'"
else
  # 4. 执行普通搜索
  eval "$RG_PREFIX '$query'"
fi

#!/usr/bin/env bash
set -f

FILE=$1
LINE=$2

# 如果文件名为空，直接退出，防止报错
if [ -z "$FILE" ]; then
    exit 0
fi

shift 2
FULL_QUERY="$*"

# 清洗引号
CLEAN_QUERY=$(printf '%s' "$FULL_QUERY" | tr -d "'\"")
LAST_WORD=$(printf '%s' "$CLEAN_QUERY" | awk '{print $NF}')

if [[ "$LAST_WORD" == -* ]] || [[ "$LAST_WORD" == *.* ]] || [[ -z "$LAST_WORD" ]]; then
    PATTERN=""
else
    PATTERN="$LAST_WORD"
fi

# ------------------------------------------------
# 【优化显示】加粗前缀 + 分行显示
# ------------------------------------------------
FILENAME=$(basename "$FILE")
DIRNAME=$(dirname "$FILE")

# 第一行：File: 文件名
# \033[1m = 加粗, \033[32m = 绿色
echo -e "\033[1mFile:\033[0m \033[1;32m$FILENAME\033[0m"

# 第二行：Path: 路径
# \033[1m = 加粗, \033[34m = 蓝色
echo -e "\033[1mPath:\033[0m \033[34m$DIRNAME/\033[0m"

# 执行预览
if [ -n "$PATTERN" ]; then
    rg --passthru \
       --pretty \
       --ignore-case \
       --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold' \
       "$PATTERN" "$FILE" 2> /dev/null
else
    if command -v batcat &> /dev/null; then BAT="batcat"; else BAT="bat"; fi
    "$BAT" --color=always --style=numbers --highlight-line "$LINE" -r "$LINE:+15" "$FILE"
fi

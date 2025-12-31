#!/usr/bin/env bash
set -f

FILE=$1
LINE=$2

if [ -z "$FILE" ]; then
    exit 0
fi

shift 2
FULL_QUERY="$*"

# 1. 【关键修改】智能提取最后一个参数
# 使用 eval set -- 重新解析参数字符串，这样能正确处理带引号的参数
# "${!#}" 是 Bash 的黑魔法，表示获取最后一个参数
eval set -- "$FULL_QUERY"
LAST_ARG="${!#}"

# 2. 过滤逻辑
if [[ "$LAST_ARG" == -* ]] || [[ "$LAST_ARG" == *.* ]] || [[ -z "$LAST_ARG" ]]; then
    PATTERN=""
else
    PATTERN="$LAST_ARG"
fi

# 3. UI 显示
FILENAME=$(basename "$FILE")
DIRNAME=$(dirname "$FILE")
echo -e "\033[1mFile:\033[0m \033[1;32m$FILENAME\033[0m"
echo -e "\033[1mPath:\033[0m \033[34m$DIRNAME/\033[0m"

# 4. 执行预览
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

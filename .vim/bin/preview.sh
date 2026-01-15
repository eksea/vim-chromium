#!/usr/bin/env bash
set -f

FILE=$1
LINE=$2

if [ -z "$FILE" ]; then
    exit 0
fi

# 接收所有剩余参数作为查询
shift 2
FULL_QUERY="$*"

# 检测 -F
FIXED_STRING=0
if [[ "$FULL_QUERY" =~ (^|[[:space:]])-F([[:space:]]|$) ]]; then
    FIXED_STRING=1
    FULL_QUERY=$(echo "$FULL_QUERY" | sed -E 's/(^|[[:space:]])-F([[:space:]]|$)/ /g')
fi

# 移除 -g
if [[ "$FULL_QUERY" =~ -g[[:space:]]+([^[:space:]]+) ]]; then
    FULL_QUERY=$(echo "$FULL_QUERY" | sed -E "s/-g[[:space:]]+[^[:space:]]+//g")
fi

# 清理空格
FULL_QUERY=$(echo "$FULL_QUERY" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')

PATTERN="$FULL_QUERY"

# 打印文件信息
FILENAME=$(basename "$FILE")
DIRNAME=$(dirname "$FILE")
echo -e "\033[1mFile:\033[0m \033[1;32m$FILENAME\033[0m"
echo -e "\033[1mPath:\033[0m \033[34m$DIRNAME/\033[0m"

# 执行预览
if [ -n "$PATTERN" ]; then
    if [ "$FIXED_STRING" -eq 1 ]; then
        rg -F --context 999 --color=always \
           --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold' \
           -- "$PATTERN" "$FILE" 2>/dev/null
    else
        if [[ "$PATTERN" =~ [A-Z] ]]; then
            rg --context 999 --color=always \
               --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold' \
               -- "$PATTERN" "$FILE" 2>/dev/null
        else
            rg -i --context 999 --color=always \
               --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold' \
               -- "$PATTERN" "$FILE" 2>/dev/null
        fi
    fi
else
    if command -v batcat &> /dev/null; then BAT="batcat"; else BAT="bat"; fi
    
    if [ -n "$FZF_PREVIEW_LINES" ]; then
        CTX_LINES=$((FZF_PREVIEW_LINES - 3))
        if [ "$CTX_LINES" -lt 1 ]; then CTX_LINES=10; fi
    else
        CTX_LINES=15
    fi

    "$BAT" --color=always --style=numbers --highlight-line "$LINE" -r "$LINE:+$CTX_LINES" "$FILE"
fi

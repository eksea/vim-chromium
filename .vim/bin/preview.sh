#!/usr/bin/env bash
set -f

FILE=$1
LINE=$2

# 1. 空值拦截
if [ -z "$FILE" ]; then
    exit 0
fi

# 丢弃前两个参数，剩下的都是查询字符串
shift 2
FULL_QUERY="$*"

# 2. 检测 -F 参数
FIXED_STRING=0
if [[ "$FULL_QUERY" =~ -F ]]; then
    FIXED_STRING=1
    FULL_QUERY=${FULL_QUERY//-F/}
fi

# 3. 移除 -g 参数
if [[ "$FULL_QUERY" =~ -g[[:space:]]+([^[:space:]]+) ]]; then
    glob="${BASH_REMATCH[1]}"
    FULL_QUERY=${FULL_QUERY//-g $glob/}
    FULL_QUERY=${FULL_QUERY//-g$glob/}
fi

# 清理首尾空格
FULL_QUERY=$(echo "$FULL_QUERY" | xargs)

# 4. 智能提取搜索词（改进版）
eval set -- "$FULL_QUERY"
LAST_ARG="${!#}"

# 【关键修复】更精确的过滤逻辑
# 只过滤明显的参数和通配符模式，不过滤普通的点号字符串
if [[ "$LAST_ARG" == -* ]]; then
    # 以 - 开头的是参数
    PATTERN=""
elif [[ "$LAST_ARG" =~ ^\*\. ]] || [[ "$LAST_ARG" =~ \.\*$ ]]; then
    # 匹配 *.cc 或 *.* 这样的通配符模式
    PATTERN=""
elif [[ -z "$LAST_ARG" ]]; then
    # 空字符串
    PATTERN=""
else
    # 其他情况都认为是有效的搜索词（包括 ew.sh, com.android.webview）
    PATTERN="$LAST_ARG"
fi

# 5. 打印文件信息
FILENAME=$(basename "$FILE")
DIRNAME=$(dirname "$FILE")
echo -e "\033[1mFile:\033[0m \033[1;32m$FILENAME\033[0m"
echo -e "\033[1mPath:\033[0m \033[34m$DIRNAME/\033[0m"

# 6. 执行预览
if [ -n "$PATTERN" ]; then
    # 【有搜索词】使用 rg 高亮
    
    # 构建基础命令
    if [ "$FIXED_STRING" -eq 1 ]; then
        # 固定字符串模式
        RG_CMD="rg -F --context 999 --color=always --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold'"
    else
        # 正则模式 + Smart Case
        if [[ "$PATTERN" =~ [A-Z] ]]; then
            # 包含大写 -> 区分大小写
            RG_CMD="rg --context 999 --color=always --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold'"
        else
            # 全小写 -> 忽略大小写
            RG_CMD="rg -i --context 999 --color=always --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold'"
        fi
    fi
    
    # 执行命令
    eval "$RG_CMD '$PATTERN' '$FILE'" 2>/dev/null
    
else
    # 【无搜索词】使用 bat 语法高亮
    if command -v batcat &> /dev/null; then BAT="batcat"; else BAT="bat"; fi
    
    if [ -n "$FZF_PREVIEW_LINES" ]; then
        CTX_LINES=$((FZF_PREVIEW_LINES - 3))
        if [ "$CTX_LINES" -lt 1 ]; then CTX_LINES=10; fi
    else
        CTX_LINES=15
    fi

    "$BAT" --color=always --style=numbers --highlight-line "$LINE" -r "$LINE:+$CTX_LINES" "$FILE"
fi

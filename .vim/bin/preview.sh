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

# 2. 检测 -F 参数（固定字符串模式）
FIXED_STRING=0
if [[ "$FULL_QUERY" =~ -F ]]; then
    FIXED_STRING=1
    # 移除 -F 参数
    FULL_QUERY=${FULL_QUERY//-F/}
fi

# 3. 移除 -g 参数（文件过滤）
if [[ "$FULL_QUERY" =~ -g[[:space:]]+([^[:space:]]+) ]]; then
    glob="${BASH_REMATCH[1]}"
    FULL_QUERY=${FULL_QUERY//-g $glob/}
    FULL_QUERY=${FULL_QUERY//-g$glob/}
fi

# 清理首尾空格
FULL_QUERY=$(echo "$FULL_QUERY" | xargs)

# 4. 智能提取搜索词
eval set -- "$FULL_QUERY"
LAST_ARG="${!#}"

# 如果最后一个词看起来像参数或文件名，则认为没有搜索词
if [[ "$LAST_ARG" == -* ]] || [[ "$LAST_ARG" == *.* ]] || [[ -z "$LAST_ARG" ]]; then
    PATTERN=""
else
    PATTERN="$LAST_ARG"
fi

# 5. 【UI 优化】打印文件信息
FILENAME=$(basename "$FILE")
DIRNAME=$(dirname "$FILE")
echo -e "\033[1mFile:\033[0m \033[1;32m$FILENAME\033[0m"
echo -e "\033[1mPath:\033[0m \033[34m$DIRNAME/\033[0m"

# 6. 执行预览
if [ -n "$PATTERN" ]; then
    # 【有搜索词】使用 rg 高亮
    
    # 6.1 构建基础参数数组
    RG_CMD=(
        rg
        --context 999              # 显示大量上下文（几乎整个文件）
        --pretty                   # 美化输出
        --colors 'match:bg:red'
        --colors 'match:fg:white'
        --colors 'match:style:bold'
    )
    
    # 6.2 处理固定字符串模式
    if [ "$FIXED_STRING" -eq 1 ]; then
        RG_CMD+=(-F)  # 添加 -F 参数
    fi
    
    # 6.3 智能大小写（Smart Case）
    if [[ "$PATTERN" =~ [A-Z] ]]; then
        # 包含大写 -> 区分大小写（不添加参数，使用默认）
        :
    else
        # 全小写 -> 忽略大小写
        RG_CMD+=(--ignore-case)
    fi
    
    # 6.4 添加搜索词和文件
    RG_CMD+=("$PATTERN" "$FILE")
    
    # 6.5 执行命令
    "${RG_CMD[@]}" 2>/dev/null
    
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

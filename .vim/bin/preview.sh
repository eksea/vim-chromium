#!/usr/bin/env bash
set -f

FILE=$1
LINE=$2

# 1. 空值拦截：防止无选中项时报错
if [ -z "$FILE" ]; then
    exit 0
fi

# 丢弃前两个参数，剩下的都是查询字符串
shift 2
FULL_QUERY="$*"

# 2. 智能提取搜索词
# 使用 eval set -- 重新解析参数，正确提取最后一个参数（即使它带引号）
eval set -- "$FULL_QUERY"
# ${!#} 是 Bash 获取最后一个参数的技巧
LAST_ARG="${!#}"

# 3. 简单的过滤逻辑
# 如果最后一个词看起来像参数(-g)或文件名(*.cc)，则认为没有搜索词
if [[ "$LAST_ARG" == -* ]] || [[ "$LAST_ARG" == *.* ]] || [[ -z "$LAST_ARG" ]]; then
    PATTERN=""
else
    PATTERN="$LAST_ARG"
fi

# 4. 【UI 优化】在顶部打印醒目的文件路径
FILENAME=$(basename "$FILE")
DIRNAME=$(dirname "$FILE")

# 第一行：File: 文件名 (加粗 + 绿色)
echo -e "\033[1mFile:\033[0m \033[1;32m$FILENAME\033[0m"
# 第二行：Path: 路径 (加粗 + 蓝色)
echo -e "\033[1mPath:\033[0m \033[34m$DIRNAME/\033[0m"

# 5. 执行预览
if [ -n "$PATTERN" ]; then
    # 【有搜索词】：使用 rg --passthru 高亮
    # --colors ...: 强制红底白字加粗，极其醒目
    rg --passthru \
       --pretty \
       --ignore-case \
       --colors 'match:bg:red' --colors 'match:fg:white' --colors 'match:style:bold' \
       "$PATTERN" "$FILE" 2> /dev/null
else
    # 【无搜索词】：回退到 bat 进行语法高亮
    if command -v batcat &> /dev/null; then BAT="batcat"; else BAT="bat"; fi
    
    # 【动态高度】根据预览窗口高度计算显示的行数
    if [ -n "$FZF_PREVIEW_LINES" ]; then
        # 减去 2 行 Header，再减 1 行余量
        CTX_LINES=$((FZF_PREVIEW_LINES - 3))
        if [ "$CTX_LINES" -lt 1 ]; then CTX_LINES=10; fi
    else
        CTX_LINES=15
    fi

    "$BAT" --color=always --style=numbers --highlight-line "$LINE" -r "$LINE:+$CTX_LINES" "$FILE"
fi

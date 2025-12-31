#!/usr/bin/env bash

RAW="$*"

# 1. 提取文件名 (保持之前的逻辑)
FILE=$(echo "$RAW" | awk -F'"' '{print $2}')
if [ -z "$FILE" ]; then
    TEMP=$(echo "$RAW" | sed 's/line [0-9]*$//')
    FILE=$(echo "$TEMP" | awk '{print $NF}')
fi

# 2. 提取行号 (关键修改)
# 先取最后一个字段，然后用 tr -cd '0-9' 删掉所有非数字字符
# 这样能确保 LINE 是纯数字，防止 bat 报错
LINE=$(echo "$RAW" | awk '{print $NF}' | tr -cd '0-9')

# 3. 兜底处理
# 如果提取出的行号为空（比如新文件没行号），默认为 1
if [ -z "$LINE" ]; then
    LINE=1
fi

# 4. 调用主预览脚本
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
"$SCRIPT_DIR/preview.sh" "$FILE" "$LINE" ""

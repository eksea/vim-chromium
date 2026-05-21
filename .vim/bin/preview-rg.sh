#!/usr/bin/env bash
# 用法: preview-rg.sh <完整原始rg行> <query>
# 从完整原始行（格式: path:line:col:content）中解析路径和行号，调用 preview.sh

set -f

RAW_LINE="$1"
shift
QUERY="$*"

if [ -z "$RAW_LINE" ]; then
  exit 0
fi

# 去掉 ANSI 色码
CLEAN=$(echo "$RAW_LINE" | sed 's/\x1b\[[0-9;]*m//g')

# 解析 path:line:col:content 格式
FILE=$(echo "$CLEAN" | cut -d: -f1)
LINE=$(echo "$CLEAN" | cut -d: -f2)

if [ -z "$FILE" ] || [ -z "$LINE" ]; then
  exit 0
fi

PREVIEW_SCRIPT="$(dirname "$0")/preview.sh"
exec "$PREVIEW_SCRIPT" "$FILE" "$LINE" "$QUERY"

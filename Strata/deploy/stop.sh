#!/bin/bash
# Strata Coder IQ1_M 服务停止脚本
# 用法: ./stop.sh
# 说明: 停止模型推理服务

set -e

PORT=8080

echo "=========================================="
echo "  Strata Coder IQ1_M 服务停止"
echo "=========================================="
echo ""

# 检查服务是否运行
if ! curl -s "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
    echo "✓ 服务未在运行"
    exit 0
fi

# 显示当前状态
echo "→ 当前服务状态:"
curl -s "http://127.0.0.1:${PORT}/health" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('  模型:', d.get('model'))
print('  上下文:', d.get('max_context'), 'tokens')
print('')
"

# 查找进程 (获取主进程 PID)
PID=$(ps aux | grep "server.py.*strata-coder" | grep -v grep | awk '{print $2}' | head -1)

if [ -z "$PID" ]; then
    echo "⚠️  未找到服务进程"
    exit 1
fi

echo "→ 停止服务 (PID: ${PID})..."

# 优雅停止
kill -TERM "$PID"

# 等待进程结束
for i in {1..30}; do
    if ! ps -p "$PID" >/dev/null 2>&1; then
        echo ""
        echo "✓ 服务已停止"
        exit 0
    fi
    echo "  等待进程退出... ${i}s"
    sleep 1
done

# 强制停止
echo ""
echo "⚠️  进程未响应，强制停止..."
kill -9 "$PID"
echo "✓ 服务已强制停止"
exit 0

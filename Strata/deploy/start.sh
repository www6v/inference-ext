#!/bin/bash
# Strata Coder IQ1_M 服务启动脚本
# 用法: ./start.sh
# 说明: 启动模型推理服务，监听 0.0.0.0:8080 支持远程访问

set -e

# 配置
STRATA_DIR="/home/wangwei/wei/workspacePy/infra-inference/Strata-main"
CONFIG="strata-coder-iq1_m.json"
PORT=8080
HOST="0.0.0.0"
LOG="/tmp/strata-server.log"

echo "=========================================="
echo "  Strata Coder IQ1_M 服务启动"
echo "=========================================="
echo ""

# 检查是否已运行
if curl -s "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
    echo "⚠️  服务已在运行中"
    curl -s "http://127.0.0.1:${PORT}/health" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('  模型:', d.get('model'))
print('  上下文:', d.get('max_context'), 'tokens')
print('  状态:', d.get('status'))
"
    exit 0
fi

# 启动服务
echo "→ 启动服务..."
echo "  目录: ${STRATA_DIR}"
echo "  配置: ${CONFIG}"
echo "  端口: ${PORT}"
echo "  日志: ${LOG}"
echo ""

cd "${STRATA_DIR}"
export STRATA_HOME=/data1/disk2/strata/config

nohup .venv/bin/python serve/server.py \
  --engine strata \
  --config "${CONFIG}" \
  --port "${PORT}" \
  --host "${HOST}" \
  > "${LOG}" 2>&1 &

PID=$!
echo "✓ 服务已启动 (PID: ${PID})"
echo ""

# 等待服务就绪
echo "→ 等待服务就绪..."
for i in {1..60}; do
    if curl -s "http://127.0.0.1:${PORT}/health" >/dev/null 2>&1; then
        echo ""
        echo "✓ 服务就绪!"
        echo ""
        curl -s "http://127.0.0.1:${PORT}/health" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('  模型:', d.get('model'))
print('  上下文:', d.get('max_context'), 'tokens')
print('  状态:', d.get('status'))
print('')
print('  API:     http://0.0.0.0:${PORT}/v1')
print('  Web UI:  http://0.0.0.0:${PORT}/')
"
        exit 0
    fi
    echo "  等待... ${i}s"
    sleep 2
done

echo ""
echo "✗ 服务启动超时，请检查日志:"
echo "  tail -f ${LOG}"
exit 1

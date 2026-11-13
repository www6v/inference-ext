#!/bin/bash
# Strata 环境配置脚本
# 设置目录、环境变量、PATH 等
#
# 用法: source setup-env.sh
#
# 注意: 此脚本需要 source 而不是直接执行

echo "=============================================="
echo "  Strata 环境配置"
echo "=============================================="
echo ""

# 配置路径 - 使用 /data1/disk2 存储模型
STRATA_BIN="$HOME/.local/bin"
STRATA_BASE="/data1/disk2/strata"
export STRATA_HOME="${STRATA_HOME:-$STRATA_BASE/config}"
export STRATA_MODELS="$STRATA_BASE/models"

# 检查目录
if [ ! -d "/data1/disk2" ]; then
    echo "错误: /data1/disk2 目录不存在"
    return 1 2>/dev/null || exit 1
fi

# 创建目录
echo "创建目录..."
mkdir -p "$STRATA_HOME"
mkdir -p "$STRATA_MODELS"
echo "  ✓ $STRATA_HOME"
echo "  ✓ $STRATA_MODELS"
echo ""

# 配置 PATH
if [[ ":$PATH:" != *":$STRATA_BIN:"* ]]; then
    export PATH="$STRATA_BIN:$PATH"
    echo "添加 PATH: $STRATA_BIN"
fi

# 写入 ~/.bashrc (如果不存在)
if ! grep -q "STRATA_HOME=/data1" ~/.bashrc 2>/dev/null; then
    # 移除旧的 strata 配置
    sed -i '/# Strata 配置/,/export PATH.*strata/d' ~/.bashrc 2>/dev/null

    cat >> ~/.bashrc << EOF

# Strata 配置 (自动添加于 $(date +%Y-%m-%d))
export STRATA_HOME=$STRATA_HOME
export STRATA_MODELS=$STRATA_MODELS
export PATH="$STRATA_BIN:\$PATH"
EOF
    echo "已写入 ~/.bashrc"
else
    echo "~/.bashrc 已包含 Strata 配置"
fi

echo ""

# 显示当前配置
echo "当前配置:"
echo "  STRATA_HOME:  $STRATA_HOME"
echo "  STRATA_MODELS: $STRATA_MODELS"
echo "  二进制目录:   $STRATA_BIN"
echo ""

# 检查磁盘空间
echo "磁盘空间:"
df -h /data1/disk2 | tail -1 | awk '{print "  /data1/disk2: " $4 " 可用 / " $2 " 总计 (" $5 " 已用)"}'
echo ""

# 检查 strata 命令
if command -v strata &> /dev/null; then
    VERSION=$(strata --version 2>/dev/null || echo 'unknown')
    echo "Strata: $VERSION ✓"
else
    echo "Strata: 未安装"
    echo ""
    echo "请先运行: ./install-strata.sh"
fi

echo ""
echo "=============================================="
echo "  环境配置完成!"
echo "=============================================="
echo ""
echo "快速开始:"
echo "  strata launch --plan --family coder --model IQ1_M  # 查看计划"
echo "  strata launch --help                               # 查看所有选项"
echo ""

#!/bin/bash
# Strata 官方安装脚本
# 从 GitHub 下载并安装 Strata Terminal
#
# 用法: ./install-strata.sh
#
# 官方文档: https://github.com/Niko1221/Strata

set -e

echo "=============================================="
echo "  Strata Terminal 安装脚本"
echo "  版本: 0.2.13 (引擎 0.1.59.1)"
echo "=============================================="
echo ""

# 检测系统
OS=$(uname -s)
ARCH=$(uname -m)
echo "系统: $OS $ARCH"

# 检测 GPU
if command -v nvidia-smi &> /dev/null; then
    GPU=$(nvidia-smi --query-gpu=name --format=csv,noheader | head -1)
    echo "GPU: $GPU"
fi
echo ""

# 安装目录
INSTALL_DIR="$HOME/.local"
STRATA_HOME="${STRATA_HOME:-/data/.strata}"

echo "安装目录: $INSTALL_DIR"
echo "配置目录: $STRATA_HOME"
echo ""

# 创建目录
mkdir -p "$STRATA_HOME"

case "$OS" in
    Linux)
        echo "正在下载 Strata Terminal (Linux x86_64)..."
        echo ""

        # 下载官方安装脚本
        curl -fsSL --connect-timeout 15 --max-time 120 \
            https://github.com/Niko1221/Strata/releases/latest/download/install.sh \
            -o /tmp/strata-official-install.sh

        # 运行安装
        sh /tmp/strata-official-install.sh

        rm -f /tmp/strata-official-install.sh
        ;;
    Darwin)
        echo "正在下载 Strata Terminal (macOS)..."
        echo ""

        curl -fsSL --connect-timeout 15 --max-time 120 \
            https://github.com/Niko1221/Strata/releases/latest/download/install.sh \
            -o /tmp/strata-official-install.sh

        sh /tmp/strata-official-install.sh

        rm -f /tmp/strata-official-install.sh
        ;;
    *)
        echo "不支持的系统: $OS"
        exit 1
        ;;
esac

echo ""
echo "=============================================="
echo "  安装完成!"
echo "=============================================="
echo ""

# 检查 strata 命令
if command -v strata &> /dev/null; then
    echo "Strata 已安装: $(strata --version 2>/dev/null || echo 'unknown')"
else
    echo "请重新打开终端或运行:"
    echo "  source ~/.bashrc"
    echo ""
    echo "或使用完整路径:"
    echo "  $HOME/.local/bin/strata --version"
fi

echo ""
echo "下一步:"
echo "  1. 查看计划:  strata launch --plan --family coder --model IQ1_M"
echo "  2. 启动模型:  strata launch --family coder --model IQ1_M --data-dir /data/strata-models"
echo "  3. 连接工具:  strata connect"
echo ""

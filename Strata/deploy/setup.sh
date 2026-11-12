#!/bin/bash
# Strata 快速部署脚本
# 基于 Strata v0.2.13 (引擎 v0.1.59)
# 官方文档: https://github.com/Niko1221/Strata
#
# 针对 RTX 3090 (24GB) + 32GB RAM 优化

set -e

# 配置 - 使用用户可写的 /data/wangwei 目录
STRATA_BASE="/data/wangwei/strata"
STRATA_MODELS="$STRATA_BASE/models"
STRATA_HOME_DIR="$STRATA_BASE/config"

echo "=============================================="
echo "  Strata v0.2.13 部署脚本"
echo "  RTX 3090 (24GB) 优化配置"
echo "=============================================="
echo ""

# 检查磁盘空间
echo "[1/6] 检查磁盘空间..."
if [ -d "/data/wangwei" ]; then
    AVAILABLE=$(df -BG /data | tail -1 | awk '{print $4}' | tr -d 'G')
    if [ "$AVAILABLE" -lt 50 ]; then
        echo "警告: /data 分区剩余空间不足 50GB (当前: ${AVAILABLE}GB)"
        read -p "是否继续? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    echo "  ✓ /data 分区可用空间: ${AVAILABLE}GB"
else
    echo "  ✗ /data/wangwei 目录不存在，请手动创建或修改脚本"
    exit 1
fi
echo ""

# 创建目录
echo "[2/6] 创建目录结构..."
mkdir -p "$STRATA_DATA"
mkdir -p "$STRATA_MODELS"
mkdir -p "$STRATA_HOME_DIR"
echo "  ✓ $STRATA_DATA"
echo "  ✓ $STRATA_MODELS"
echo "  ✓ $STRATA_HOME_DIR"
echo ""

# 安装 Strata
echo "[3/6] 安装 Strata Terminal..."
if command -v strata &> /dev/null; then
    VERSION=$(strata --version 2>/dev/null || echo 'unknown')
    echo "  ✓ Strata 已安装: $VERSION"
else
    echo "  正在下载安装..."
    curl -fsSL --connect-timeout 15 --max-time 120 \
        https://github.com/Niko1221/Strata/releases/latest/download/install.sh \
        -o /tmp/strata-install.sh
    sh /tmp/strata-install.sh
    rm /tmp/strata-install.sh
    echo "  ✓ 安装完成"
fi
echo ""

# 配置环境变量
echo "[4/6] 配置环境变量..."
STRATA_BIN="$HOME/.local/bin"

# 检查是否已在 PATH 中
if ! grep -q "STRATA_HOME" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << EOF

# Strata 配置 (自动添加于 $(date +%Y-%m-%d))
export STRATA_HOME=$STRATA_HOME_DIR
export PATH="$STRATA_BIN:\$PATH"
EOF
    echo "  ✓ 已添加到 ~/.bashrc"
else
    echo "  ✓ 环境变量已配置"
fi

# 当前 session
export STRATA_HOME="$STRATA_HOME_DIR"
export PATH="$STRATA_BIN:$PATH"
echo ""

# 选择模型
echo "[5/6] 选择要部署的模型:"
echo ""
echo "  推荐顺序: ISTA-DASLab → Unsloth → Gyro → 其他"
echo ""
echo "  ISTA-DASLab Qwen3.8-Flash-Next 模型 (完整版 512 experts):"
echo "  ┌──────────┬──────────┬──────────┬──────────┐"
echo "  │ 模型     │ 内存需求 │ 本机适配 │ 说明     │"
echo "  ├──────────┼──────────┼──────────┼──────────┤"
echo "  │ Q2_0     │ 37.6 GB  │ ⚠️ low-ram │ 最快    │"
echo "  │ IQ2_XS   │ 39.2 GB  │ ⚠️ low-ram │ 更好    │"
echo "  │ IQ3_XXS  │ 47.0 GB  │ ❌       │ great   │"
echo "  │ IQ3_S    │ 54.8 GB  │ ❌       │ best    │"
echo "  └──────────┴──────────┴──────────┴──────────┘"
echo ""
echo "  Coder (Qwen3.8-Flash-Next 编程版 256 experts):"
echo "  ┌──────────┬──────────┬──────────┬──────────┐"
echo "  │ IQ1_M    │ ~32 GB   │ ✅ 正常   │ 编程专用│"
echo "  └──────────┴──────────┴──────────┴──────────┘"
echo ""
echo "  部署选项:"
echo "  1) Coder IQ1_M     - 编程版，内存友好 (推荐)"
echo "  2) Qwen Q2_0       - 完整版，支持图片 (low-ram 模式)"
echo "  3) Qwen IQ2_XS     - 完整版更高质量 (low-ram 模式)"
echo "  4) Qwen36 UD-Q4_K  - Qwen3.6-35B-A3B MoE 轻量模型"
echo "  5) 跳过 (手动运行 strata launch)"
echo ""
read -p "请选择 [1-5] (默认: 1): " choice
choice=${choice:-1}

case $choice in
    1)
        MODEL_FAMILY="coder"
        MODEL_NAME="IQ1_M"
        ;;
    2)
        MODEL_FAMILY="qwen"
        MODEL_NAME="q2_0"
        ;;
    3)
        MODEL_FAMILY="qwen"
        MODEL_NAME="iq2_xs"
        ;;
    4)
        MODEL_FAMILY="qwen36"
        MODEL_NAME="UD-Q4_K_XL"
        ;;
    5)
        echo ""
        echo "跳过模型下载。稍后可运行:"
        echo "  strata launch --data-dir $STRATA_MODELS"
        MODEL_FAMILY=""
        MODEL_NAME=""
        ;;
    *)
        echo "无效选择，使用默认 (Coder)"
        MODEL_FAMILY="coder"
        MODEL_NAME="IQ1_M"
        ;;
esac

if [ -n "$MODEL_FAMILY" ]; then
    echo ""
    echo "准备启动: --family $MODEL_FAMILY --model $MODEL_NAME"
    echo ""

    # 先显示计划
    echo "部署计划:"
    strata launch --plan --family "$MODEL_FAMILY" --model "$MODEL_NAME" --data-dir "$STRATA_MODELS" 2>/dev/null || true
    echo ""

    read -p "是否开始下载并启动? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "[6/6] 启动模型..."
        echo ""
        echo "提示:"
        echo "  - 首次下载模型可能需要较长时间"
        echo "  - 按 Ctrl+C 可中断，下次运行会续传"
        echo "  - 使用 strata launch --status 查看状态"
        echo ""
        sleep 2

        strata launch \
            --family "$MODEL_FAMILY" \
            --model "$MODEL_NAME" \
            --data-dir "$STRATA_MODELS" \
            --yes \
            --no-tui
    fi
fi

echo ""
echo "=============================================="
echo "  部署完成!"
echo "=============================================="
echo ""
echo "后续操作:"
echo "  - 启动模型:  strata launch --family $MODEL_FAMILY --model $MODEL_NAME --data-dir $STRATA_MODELS"
echo "  - 查看状态:  strata launch --status"
echo "  - 连接工具:  strata connect"
echo "  - 停止模型:  strata launch --stop"
echo ""
echo "API 端点 (启动后可用):"
echo "  - OpenAI 兼容:    http://127.0.0.1:8080/v1"
echo "  - Anthropic 兼容: http://127.0.0.1:8080"
echo "  - 健康检查:       http://127.0.0.1:8080/health"
echo ""
echo "工具集成:"
echo "  - Claude Code:  export ANTHROPIC_BASE_URL=http://127.0.0.1:8080"
echo "  - Codex CLI:    export OPENAI_BASE_URL=http://127.0.0.1:8080/v1"
echo ""
echo "参考文档:"
echo "  - https://github.com/Niko1221/Strata"
echo "  - https://github.com/Niko1221/Strata/blob/main/docs/MODELS.md"
echo ""

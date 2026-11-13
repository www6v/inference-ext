#!/bin/bash
# Strata Coder IQ1_M 模型下载脚本
# 从 HuggingFace 镜像下载完整模型文件
#
# 用法: ./download-model.sh

set -e

MODEL_DIR="/data1/disk2/strata/models/models/coder-IQ1_M"
MIRROR="https://hf-mirror.com"
REPO="ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF"

echo "=============================================="
echo "  Strata Coder IQ1_M 模型下载"
echo "=============================================="
echo ""

# 创建目录
mkdir -p "$MODEL_DIR"

# 文件列表
FILES=(
  "IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf"
  "IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf"
)

# 并行下载
echo "开始并行下载..."
echo ""

for file in "${FILES[@]}"; do
  filename=$(basename "$file")
  url="$MIRROR/$REPO/resolve/main/$file"
  output="$MODEL_DIR/$filename"

  if [ -f "$output" ]; then
    echo "✓ $filename 已存在，跳过"
  else
    echo "↓ 下载 $filename ..."
    curl -L --progress-bar "$url" -o "$output" &
  fi
done

# 等待所有下载完成
wait

echo ""
echo "=============================================="
echo "  下载完成!"
echo "=============================================="
echo ""
ls -lh "$MODEL_DIR"
echo ""
echo "下一步: 运行 setup 完成配置"
echo "  cd /home/wangwei/wei/workspacePy/infra-inference/Strata-main"
echo "  export STRATA_HOME=/data1/disk2/strata/config"
echo "  ./setup.sh --family coder --model IQ1_M --data-dir /data1/disk2/strata/models \\"
echo "    --gguf-dir $MODEL_DIR --context 32768 --vision no --mtp off \\"
echo "    --prebuilt /data1/disk2/strata/engine --setup --no-start --yes"

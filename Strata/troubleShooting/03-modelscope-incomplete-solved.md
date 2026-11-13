# 问题: ModelScope 模型文件不完整

## 日期
2026-11-13

## 问题描述
ModelScope 上的 Coder IQ1_M 模型文件不完整：
1. 第2个分片文件 (00002-of-00002) 返回 404
2. 第1个分片文件 SHA-256 与 Strata 期望不匹配

## 解决方案
使用 HuggingFace 镜像 (hf-mirror.com) 下载完整模型文件。

### 关键发现
HuggingFace 上的文件路径包含子目录：
- `IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf`
- `IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf`

### 下载命令
```bash
# 文件 1
curl -L "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf" \
  -o /data1/disk2/strata/models/models/coder-IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf

# 文件 2
curl -L "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf" \
  -o /data1/disk2/strata/models/models/coder-IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf
```

### 并行下载
可以同时下载两个文件以加快速度：
```bash
curl -L "URL1" -o file1 &
curl -L "URL2" -o file2 &
wait
```

## 状态
✅ 已解决 - 使用 hf-mirror.com 成功下载完整模型

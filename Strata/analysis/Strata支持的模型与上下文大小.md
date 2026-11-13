# Strata 支持的模型与上下文大小

> 整理日期：2026-11-13
> 数据来源：`Strata-main/README.md` + `Strata-main/docs/MODELS.md`

---

## 一、支持的模型系列

### 1. Qwen3.8-Flash-Next（推荐）

| 提供商 | 可用尺寸 | 内存需求 (RAM+VRAM) | 适用场景 |
|--------|----------|---------------------|----------|
| **ISTA-DASLab** | Q2_0 | 37 GB | 通用 |
| | IQ2_XS | 40 GB | 通用 |
| | IQ3_XXS | 46 GB | 通用 |
| | IQ3_S | 55 GB | 通用 |
| | **IQ1_M (Coder)** | **~32 GB** | **编程专用** |
| **Unsloth** | UD-IQ4_XS | 72 GB | 通用 |
| | UD-Q4_K_XL | 90 GB | 通用 |
| | UD-Q5_K_XL | 108 GB | 通用 |
| | UD-Q6_K_XL | 120 GB | 通用 |
| | Q8_0 | 136 GB | 通用 |
| **Gyro** | Gyro-S | 27 GB | 通用（低内存） |
| | Gyro-M | 35 GB | 通用（低内存） |
| **NVFP4** | NVFP4 | ~80 GB | NVIDIA 专用 |

### 2. Qwen3.6-35B-A3B（MoE 大模型）

| 提供商 | 可用尺寸 | 内存需求 (RAM+VRAM) |
|--------|----------|---------------------|
| **Unsloth** | UD-Q4_K_XL | 32 GB |
| | UD-Q6_K_XL | 42 GB |
| | Q8_0 | 52 GB |

### 3. DeepSeek V4.1-Flash-1017（672B 参数 MoE）

| 集合 | 下载大小 | 所需磁盘空间 |
|------|----------|--------------|
| 1.75 bpw | 239 GB | ~245 GB |
| 2.00 bpw | 257 GB | ~265 GB |
| 2.25 bpw | 274 GB | ~280 GB |
| **Coder** | **191 GB** | **~197 GB** |

---

## 二、上下文大小

| 模型系列 | 默认上下文 | 支持的最大上下文 | 说明 |
|----------|-----------|------------------|------|
| **Qwen3.8-Flash-Next** | 32K (32,768 tokens) | 128K+（实验性可达 512K） | 线性注意力 + 全注意力混合架构，≤262144 无需 rope scaling |
| **Qwen3.6-35B-A3B** | 32K | 128K | MoE 架构，35B 参数中仅 3B 激活 |
| **DeepSeek V4.1-Flash** | **8K** | **8K（固定）** | 672B 参数，expert 流式加载 |

---

## 三、当前部署的模型

| 项目 | 值 |
|------|-----|
| **模型** | Qwen3.8-Flash-Next Coder (IQ1_M) |
| **上下文** | **131,072 tokens (128K)** ✅ |
| **适用场景** | 编程专用 |
| **内存需求** | ~38 GB（KV Cache ~8 GB） |
| **API 端点** | http://192.168.3.4:8080/v1 |
| **Output 速度** | 61.6 tok/s |
| **Prompt 速度** | 96.3 tok/s |

---

## 四、模型选择建议

| 使用场景 | 推荐模型 | 原因 |
|----------|----------|------|
| **编程助手** | Qwen3.8-Flash-Next Coder (IQ1_M) | 编程优化，128K 上下文 |
| **通用对话** | Qwen3.8-Flash-Next IQ3_S | 质量与性能平衡 |
| **低内存设备** | Gyro-S / Gyro-M | 更低内存需求 |
| **大上下文** | Qwen3.8-Flash-Next (128K+) | 最长上下文支持 |
| **最大模型** | DeepSeek V4.1-Flash | 672B 参数，但仅 8K 上下文 |
| **MoE 平衡** | Qwen3.6-35B-A3B | 35B 参数，3B 激活，32K 上下文 |

---

## 五、重要限制

### Claude Code 兼容性

| 工具 | 提示词大小 | 上下文需求 | 是否兼容 |
|------|-----------|-----------|----------|
| **Claude Code** | ~73K tokens | 200K+ | ⚠️ 128K 勉强可用（仍可能截断） |
| **pi / oh-my-pi** | 较小 | 智能截断 | ✅ 兼容 |
| **Continue** | 较小 | 智能截断 | ✅ 兼容 |
| **Aider** | 较小 | 智能截断 | ✅ 兼容 |

### 原因

Claude Code 的 system prompt + 工具定义 + 对话历史约 **73K tokens**。

| 上下文配置 | 是否兼容 | 说明 |
|-----------|----------|------|
| 32K | ❌ | 73K > 32K，必然失败 |
| **128K** | **⚠️** | 73K < 128K，但留给回复的空间仅 55K，长对话仍可能截断 |
| 200K+ | ✅ | 73K < 200K，有足够空间 |

```
API Error: 400 request exceeds the context window: 
prompt (73777 tokens) leaves no room to answer in the context (32768)
```

---

## 六、性能参考

### Qwen3.8-Flash-Next Q2_0（RTX 5070 12GB, Ryzen 5 7600）

| 场景 | Prompt 速度 | Output 速度 |
|------|------------|-------------|
| 1K 上下文 | 536 tok/s | 87.3 tok/s |
| 32K 上下文 | 2171 tok/s | 81.8 tok/s |
| 262K 上下文 | 1304 tok/s | 60.3 tok/s |

### 当前部署（Coder IQ1_M, RTX 3090 24GB）

| 指标 | 数值 |
|------|------|
| **Output 速度** | 61.6 tok/s |
| **Prompt 速度** | 96.3 tok/s |
| **上下文窗口** | **128K tokens (131,072)** |

### 上下文与性能关系

| 上下文 | KV Cache | Output 速度 | 说明 |
|--------|----------|-------------|------|
| 32K | ~2 GB | ~82 tok/s | 默认配置 |
| **128K** | **~8 GB** | **~62 tok/s** | **当前配置** |
| 256K | ~16 GB | ~50 tok/s | 需要更多内存 |

---

## 七、文件结构

```
/data1/disk2/strata/models/
├── models/coder-IQ1_M/
│   ├── Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf (28 GB)
│   └── Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf (27 GB)
├── packs/coder-iq1_m/
│   ├── experts.bin (23 GB, CPU expert 权重)
│   └── index.txt (1079 tensors)
└── mtp/ (未下载，MTP draft layer ~5 GB)
```

---

## 八、上下文配置

### 可选上下文值

| 上下文 | 值 | 是否需要 Rope Scaling |
|--------|-----|----------------------|
| 8K | 8,192 | ❌ |
| **32K (默认)** | 32,768 | ❌ |
| 64K | 65,536 | ❌ |
| **128K** | **131,072** | **❌** |
| 200K | 204,800 | ❌ |
| 256K | 262,144 | ❌ |
| 384K | 393,216 | ✅ (yarn) |
| 512K | 524,288 | ✅ (yarn) |

### 配置方法

**方法 1：修改配置文件**

编辑 `strata-coder-iq1_m.json`，修改 `--max-context` 值：

```json
{
  "args": [
    ...
    "--max-context",
    "131072",
    ...
  ]
}
```

**方法 2：setup 时指定**

```bash
./setup.sh --family coder --model IQ1_M \
  --data-dir /data1/disk2/strata/models \
  --context 131072 \
  --vision no \
  --prebuilt /data1/disk2/strata/engine \
  --setup --no-start --yes
```

### 内存影响

| 上下文 | KV Cache 大小 | 总内存需求 |
|--------|--------------|-----------|
| 32K | ~2 GB | ~32 GB |
| 64K | ~4 GB | ~34 GB |
| **128K** | **~8 GB** | **~38 GB** |
| 256K | ~16 GB | ~46 GB |

---

## 九、下载源

| 来源 | 优点 | 缺点 |
|------|------|------|
| **HuggingFace** | 官方源，文件完整 | 国内访问困难 |
| **hf-mirror.com** | 国内可访问，文件完整 | 镜像可能延迟 |
| **ModelScope** | 国内官方源 | 部分文件不完整（如 Coder 模型） |

### 推荐下载命令

```bash
# 使用 hf-mirror 并行下载
curl -L "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00001-of-00002.gguf" \
  -o model1.gguf &

curl -L "https://hf-mirror.com/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-Coder-GGUF/resolve/main/IQ1_M/Qwen3.8-Flash-Next-GSQ-RCO-IQ1_M-00002-of-00002.gguf" \
  -o model2.gguf &

wait
```

---

*本文档基于 Strata v0.2.13 项目文档整理。*

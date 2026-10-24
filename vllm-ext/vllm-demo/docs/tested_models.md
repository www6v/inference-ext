# vLLM Benchmark 测试过的模型记录

本文档记录了在 vLLM GPU Benchmark 项目中尝试过的所有大语言模型，包括测试结果和遇到的问题。

## 测试环境

| 项目 | 规格 |
|------|------|
| GPU | NVIDIA GeForce RTX 3090 |
| 显存 | 24 GB |
| Python | 3.13 |
| vLLM | 0.28.0 |
| CUDA | 13.0 |

---

## 尝试过的模型列表

### 1. QuantTrio/Qwen3.5-27B-AWQ ❌

| 项目 | 值 |
|------|-----|
| 模型类型 | 密集模型 (Dense) |
| 参数量 | ~27B |
| 量化精度 | 4-bit AWQ |
| 权重文件大小 | ~24 GB (8 个 safetensors 文件) |
| 下载来源 | HuggingFace |
| 模型路径 | `/data/models/vllm_benchmark/QuantTrio_Qwen3.5-27B-AWQ/` |
| 测试状态 | **失败 - OOM** |

**失败原因：**
- 模型加载成功（耗时约 8 秒）
- 但在初始化 KV cache 时显存不足
- 错误：`CUDA out of memory. Tried to allocate 356515840 bytes (free: 27852800, total: 25295519744)`
- 加载后仅剩约 27MB 显存剩余

**尝试的解决方案：**
- 降低 `gpu_memory_utilization` 到 0.7
- 减少 `max_model_len` 到 2048
- 使用 `VLLM_USE_V1=0` 切换到 V0 引擎
- 以上均无效

---

### 2. cyankiwi/Qwen3.8-27B-AWQ-INT4 ❌

| 项目 | 值 |
|------|-----|
| 模型类型 | 密集模型 (Dense) |
| 参数量 | ~27B |
| 量化精度 | 4-bit AWQ (INT4) |
| 权重文件大小 | ~20 GB (5 个 safetensors 文件) |
| 下载来源 | ModelScope |
| 模型路径 | `/data/models/vllm_benchmark/models/cyankiwi--Qwen3.8-27B-AWQ-INT4/` |
| 测试状态 | **失败 - OOM + 量化方法不匹配** |

**失败原因：**
- 模型配置使用 `compressed-tensors` 量化
- 与 vLLM 的 `quantization='awq'` 参数不兼容
- 错误：`Quantization method specified in the model config (compressed-tensors) does not match the quantization method specified in the quantization argument (awq)`
- 即使使用 auto-detect 量化，仍然 OOM

---

### 3. cyankiwi/Qwen3.6-35B-A3B-AWQ-4bit ❌

| 项目 | 值 |
|------|-----|
| 模型类型 | **MoE (Mixture of Experts)** |
| 总参数量 | ~35B |
| 激活参数量 | ~3.6B (每 token 激活 8/256 专家) |
| 量化精度 | 4-bit AWQ |
| 权重文件大小 | ~28 GB (6 个 safetensors 文件) |
| 下载来源 | ModelScope |
| 模型路径 | `/data/models/vllm_benchmark/models/cyankiwi--Qwen3.6-35B-A3B-AWQ-4bit/` |
| 测试状态 | **失败 - OOM** |

**模型架构详情：**
```json
{
  "architectures": ["Qwen3_5MoeForConditionalGeneration"],
  "num_hidden_layers": 40,
  "hidden_size": 2048,
  "num_attention_heads": 16,
  "num_experts": 256,
  "num_experts_per_tok": 8,
  "moe_intermediate_size": 512,
  "quantization_config": {
    "quant_method": "awq",
    "bits": 4,
    "group_size": 32
  }
}
```

**失败原因：**
- 模型加载成功（耗时约 17 秒）
- 但在 Profile 阶段显存不足
- 错误：`CUDA out of memory. Tried to allocate 64.00 MiB. GPU 0 has a total capacity of 23.56 GiB of which 81.81 MiB is free.`
- 已尝试的设置：
  - `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True`
  - `gpu_memory_utilization=0.5` (50%)
  - `max_model_len=512`

**分析：**
虽然这是 MoE 模型，每 token 只激活 3.6B 参数，但**所有专家权重都需要加载到显存中**，因此显存占用与密集模型相当。

---

## 失败原因总结

| 模型 | 参数量 | 量化 | 显存需求 (估计) | 实际显存 | 结果 |
|------|--------|------|----------------|----------|------|
| Qwen3.5-27B-AWQ | 27B | 4-bit | ~16-18 GB + KV cache | 24 GB | ❌ OOM |
| Qwen3.8-27B-AWQ-INT4 | 27B | 4-bit | ~14-16 GB + KV cache | 24 GB | ❌ OOM |
| Qwen3.6-35B-A3B-AWQ | 35B (MoE) | 4-bit | ~20-22 GB + KV cache | 24 GB | ❌ OOM |

### 核心问题

1. **24GB 显存不足以运行 27B+ 参数的 4-bit 量化模型**
   - 模型权重加载后，剩余显存不足以分配 KV cache 和临时缓冲区
   - vLLM 的 V1 引擎在初始化时需要额外的显存开销

2. **MoE 模型的显存优势不在加载时**
   - MoE 只在推理时激活部分专家
   - 但所有专家权重仍需加载到显存
   - 显存占用与同规模密集模型相当

### 尝试过的所有解决方案

| 方案 | 结果 |
|------|------|
| 降低 `gpu_memory_utilization` | ❌ 仍然 OOM |
| 减少 `max_model_len` | ❌ 仍然 OOM |
| 使用 V0 引擎 (`VLLM_USE_V1=0`) | ❌ 仍然 OOM |
| 设置 `PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True` | ❌ 仍然 OOM |
| 切换 attention_backend | ❌ flashinfer 编译失败 |
| 移除 quantization 参数（auto-detect） | ❌ 仍然 OOM |

---

## 成功运行的模型

### Qwen/Qwen3.5-9B ✅

| 项目 | 值 |
|------|-----|
| 模型类型 | 密集模型 (Dense) |
| 参数量 | ~9B |
| 量化精度 | BF16 |
| 权重文件大小 | ~18 GB (4 个 safetensors 文件) |
| 下载来源 | ModelScope |
| 模型路径 | `/data/models/vllm_benchmark/models/Qwen--Qwen3.5-9B/snapshots/master` |
| 测试状态 | **成功** |
| 测试日期 | 2026-09-08 |

**测试结果：**

| 生成长度 | 耗时 | 吞吐量 |
|---------|------|--------|
| 32 tokens | 2.04s | 15.7 tok/s |
| 128 tokens | 7.47s | 17.1 tok/s |
| 256 tokens | 15.03s | 17.0 tok/s |

**显存占用：**
- 模型权重：17.98 GB
- 激活内存：1.81 GB
- KV cache：1.42 GB
- 总计：~21.2 GB（在 24GB 显存内正常运行）

---

## 推荐方案

要在当前 RTX 3090 (24GB) 上成功运行 vLLM benchmark，建议使用以下模型：

### 推荐模型列表

| 模型 | 参数量 | 显存需求 | 来源 |
|------|--------|----------|------|
| Qwen2.5-7B-Instruct-AWQ | 7B | ~5-6 GB | ModelScope |
| Qwen2.5-14B-Instruct-AWQ | 14B | ~9-10 GB | ModelScope |
| Qwen3.5-30B-A3B-AWQ-4bit | 30B (MoE, 3B 激活) | ~12-14 GB | ModelScope |
| Qwen/Qwen3.5-9B | 9B | ~21 GB | ModelScope ✅ |

### 建议测试顺序

1. **Qwen/Qwen3.5-9B** - 已成功测试，9B 参数在 24GB 显存上运行良好
2. **Qwen2.5-7B-Instruct-AWQ** - 最稳妥，显存占用最低
3. **Qwen2.5-14B-Instruct-AWQ** - 中等规模，性能与显存的平衡
4. **更小 MoE 模型** - 如 Qwen3.5-30B-A3B（激活 3B 参数）

---

## 附录：模型下载命令

```bash
# 从 ModelScope 下载
source .venv/bin/activate
python -c "
from modelscope import snapshot_download
download_path = snapshot_download('qwen/Qwen2.5-7B-Instruct-AWQ', cache_dir='/data/models/vllm_benchmark')
print(f'Download path: {download_path}')
"
```

## 附录：vLLM Benchmark 运行命令

```bash
# 运行 benchmark
source .venv/bin/activate
python -m vllm_benchmark \
  --model /data/models/vllm_benchmark/models/qwen--Qwen2.5-7B-Instruct-AWQ/snapshots/master \
  --gpu-memory-utilization 0.9 \
  --max-model-len 4096 \
  --output results/qwen2_5_7b_awq_benchmark.json
```

---

*文档生成时间：2026-09-08*
